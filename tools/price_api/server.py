#!/usr/bin/env python3
"""Canlı fiyat API — sepet karşılaştırması.

Uygulama market sitelerine gitmez; bu servis gider. Her fiyat, ürünün kendi
sayfasından okunur ve doğrulanır.

Örnek::

    python3 -m price_api.server --port 8080

    curl -X POST http://localhost:8080/v1/compare/stream \\
      -H 'Content-Type: application/json' \\
      -d '{"region":"istanbul","items":[{"productId":"sut-1l__icim","quantity":1}]}'
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

TOOLS = Path(__file__).resolve().parents[1]
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from price_sync.catalog import REPO, fold, load_catalog  # noqa: E402

from price_api.market_fiyati import search as mf_search  # noqa: E402
from price_api.quote import (  # noqa: E402
    ALL_MARKET_SLUGS,
    SLUG_TO_MARKET,
    compare_all,
    compare_stream,
    quote_market,
)

CACHE_DIR = REPO / '.price_sync_cache'
BOOK_PATH = REPO / 'lib' / 'data' / 'price_book.dart'


def search_catalog(query: str, region: str | None = None) -> list[dict]:
    catalog = load_catalog()
    words = [w for w in re.split(r'\s+', fold(query.strip())) if w]
    hits = []
    for type_ in catalog.types:
        haystack = fold(f'{type_.name} {type_.category} {type_.unit}')
        if words and not all(w in haystack for w in words):
            continue
        hits.append({
            'id': type_.id,
            'name': type_.name,
            'category': type_.category,
            'unit': type_.unit,
            'source': 'local',
        })
    live = []
    if query.strip():
        try:
            for product in mf_search(query.strip(), region=region, size=24):
                live.append({
                    'id': f'mf:{product.id}',
                    'name': product.title,
                    'category': product.category,
                    'unit': 'adet',
                    'brand': product.brand,
                    'volume': product.volume,
                    'source': 'marketFiyati',
                    'marketCount': len(product.cheapest_by_market()),
                })
        except Exception:  # noqa: BLE001
            pass
    return live + hits


class Handler(BaseHTTPRequestHandler):
    server_version = 'SepetPriceAPI/1.0'

    def log_message(self, fmt: str, *args) -> None:
        sys.stderr.write('%s - %s\n' % (self.address_string(), fmt % args))

    def _send_json(self, payload: dict | list, status: int = 200) -> None:
        body = json.dumps(payload, ensure_ascii=False).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()
        self.wfile.write(body)

    def _read_json(self) -> dict:
        length = int(self.headers.get('Content-Length', '0'))
        raw = self.rfile.read(length) if length else b'{}'
        parsed = json.loads(raw.decode('utf-8') or '{}')
        if not isinstance(parsed, dict):
            raise ValueError('JSON gövdesi nesne olmalı')
        return parsed

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        path = parsed.path.rstrip('/') or '/'
        if path == '/health':
            self._send_json({'ok': True})
            return
        if path == '/v1/catalog/search':
            query = parse_qs(parsed.query).get('q', [''])[0]
            region = parse_qs(parsed.query).get('region', [None])[0]
            self._send_json({'results': search_catalog(query, region)})
            return
        self._send_json({'error': 'bulunamadı'}, 404)

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        path = parsed.path.rstrip('/') or '/'
        try:
            body = self._read_json()
        except (json.JSONDecodeError, ValueError) as exc:
            self._send_json({'error': str(exc)}, 400)
            return

        items = body.get('items') or []
        region = body.get('region')

        market_match = re.fullmatch(r'/v1/markets/([^/]+)/quotes', path)
        if market_match:
            slug = market_match.group(1)
            batch = quote_market(
                slug=slug,
                items=items,
                region=region,
                book_path=BOOK_PATH,
                cache_dir=CACHE_DIR,
            )
            self._send_json(batch)
            return

        if path == '/v1/compare':
            result = compare_all(
                items=items,
                region=region,
                book_path=BOOK_PATH,
                cache_dir=CACHE_DIR,
            )
            self._send_json(result)
            return

        if path == '/v1/compare/stream':
            self._stream_compare(items, region)
            return

        self._send_json({'error': 'bulunamadı'}, 404)

    def _stream_compare(self, items: list, region: str | None) -> None:
        self.send_response(200)
        self.send_header('Content-Type', 'application/x-ndjson; charset=utf-8')
        self.send_header('Cache-Control', 'no-cache')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        for chunk in compare_stream(
            items=items,
            region=region,
            book_path=BOOK_PATH,
            cache_dir=CACHE_DIR,
        ):
            line = json.dumps(chunk, ensure_ascii=False).encode('utf-8') + b'\n'
            self.wfile.write(line)
            self.wfile.flush()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--host', default='0.0.0.0')
    parser.add_argument('--port', type=int, default=8080)
    args = parser.parse_args()

    httpd = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f'Fiyat API dinliyor: http://{args.host}:{args.port}')
    print(f'Marketler: {", ".join(ALL_MARKET_SLUGS)}')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print('\nDurduruldu.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
