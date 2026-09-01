"""Canlı fiyat API önbelleği: sayfa HTML + kalıcı SKU dizini."""

from __future__ import annotations

import json
import threading
import time
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path

from price_sync.matching import Offer


def _iso_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


@dataclass
class CachedPage:
    title: str
    text: str
    fetched_at: float


class PageCache:
    """Ürün sayfası HTML önbelleği — aynı sepet yenilemesinde tekrar indirmez."""

    def __init__(self, ttl_seconds: float = 45.0):
        self.ttl_seconds = ttl_seconds
        self._lock = threading.Lock()
        self._pages: dict[str, CachedPage] = {}

    def get(self, url: str) -> tuple[str, str] | None:
        with self._lock:
            entry = self._pages.get(url)
            if entry is None:
                return None
            if time.monotonic() - entry.fetched_at > self.ttl_seconds:
                del self._pages[url]
                return None
            return entry.title, entry.text

    def put(self, url: str, title: str, text: str) -> None:
        with self._lock:
            self._pages[url] = CachedPage(title=title, text=text, fetched_at=time.monotonic())


@dataclass
class SkuRecord:
    url: str
    price: float
    name: str
    fetched_at: str
    in_stock: bool = True

    def to_offer(self, market: str) -> Offer:
        return Offer(
            market=market,
            name=self.name,
            url=self.url,
            price=self.price,
            in_stock=self.in_stock,
        )


class SkuIndex:
    """productId → market → doğrulanmış ürün sayfası.

    Defterden bağımsız büyür: canlı çekimde bulunan her URL burada kalır,
    sonraki isteklerde arama yapmadan doğrudan sayfa açılır.
    """

    def __init__(self, path: Path):
        self.path = path
        self._lock = threading.Lock()
        self._data: dict[str, dict[str, SkuRecord]] = {}
        self._load()

    def _load(self) -> None:
        if not self.path.exists():
            return
        try:
            raw = json.loads(self.path.read_text(encoding='utf-8'))
        except (json.JSONDecodeError, OSError):
            return
        for product_id, markets in raw.items():
            if not isinstance(markets, dict):
                continue
            bucket: dict[str, SkuRecord] = {}
            for market, record in markets.items():
                if isinstance(record, dict) and record.get('url'):
                    bucket[market] = SkuRecord(**record)
            if bucket:
                self._data[product_id] = bucket

    def get(self, product_id: str, market: str) -> SkuRecord | None:
        with self._lock:
            return self._data.get(product_id, {}).get(market)

    def put(self, product_id: str, market: str, offer: Offer) -> None:
        with self._lock:
            self._data.setdefault(product_id, {})[market] = SkuRecord(
                url=offer.url,
                price=offer.price,
                name=offer.name,
                fetched_at=_iso_now(),
                in_stock=offer.in_stock,
            )
            self._persist()

    def _persist(self) -> None:
        payload = {
            product_id: {
                market: asdict(record)
                for market, record in markets.items()
            }
            for product_id, markets in self._data.items()
        }
        self.path.parent.mkdir(parents=True, exist_ok=True)
        tmp = self.path.with_suffix('.tmp')
        tmp.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding='utf-8')
        tmp.replace(self.path)
