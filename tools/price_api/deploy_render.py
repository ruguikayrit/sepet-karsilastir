#!/usr/bin/env python3
"""Render'da price API servisini oluşturur veya yeniden deploy eder.

Gerekli ortam değişkenleri:
  RENDER_API_KEY   — https://dashboard.render.com/u/settings#api-keys
  RENDER_OWNER_ID  — Workspace Settings sayfasındaki ID

Örnek:
  export RENDER_API_KEY=rnd_...
  export RENDER_OWNER_ID=tea-...
  python3 tools/price_api/deploy_render.py
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request

API = 'https://api.render.com/v1'
REPO = 'https://github.com/ruguikayrit/sepet-karsilastir'
SERVICE_NAME = 'sepet-price-api'


def _request(method: str, path: str, body: dict | None = None) -> dict | list:
    key = os.environ.get('RENDER_API_KEY', '').strip()
    if not key:
        raise SystemExit('RENDER_API_KEY tanımlı değil.')

    data = None
    headers = {
        'Authorization': f'Bearer {key}',
        'Accept': 'application/json',
    }
    if body is not None:
        data = json.dumps(body).encode('utf-8')
        headers['Content-Type'] = 'application/json'

    req = urllib.request.Request(f'{API}{path}', data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            raw = resp.read().decode('utf-8')
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode('utf-8', errors='replace')
        raise SystemExit(f'HTTP {exc.code}: {detail}') from exc


def _find_service(owner_id: str) -> dict | None:
    cursor = None
    while True:
        path = f'/services?ownerId={owner_id}&limit=100'
        if cursor:
            path += f'&cursor={cursor}'
        page = _request('GET', path)
        if not isinstance(page, list):
            break
        for row in page:
            service = row.get('service') or row
            if service.get('name') == SERVICE_NAME:
                return service
        cursor = page[-1].get('cursor') if page else None
        if not cursor:
            break
    return None


def _create_service(owner_id: str) -> dict:
    payload = {
        'type': 'web_service',
        'name': SERVICE_NAME,
        'ownerId': owner_id,
        'repo': REPO,
        'branch': 'master',
        'autoDeploy': 'yes',
        'envVars': [
            {'key': 'PYTHONUNBUFFERED', 'value': '1'},
        ],
        'serviceDetails': {
            'runtime': 'docker',
            'plan': 'free',
            'region': 'frankfurt',
            'healthCheckPath': '/health',
            'envSpecificDetails': {
                'dockerfilePath': './Dockerfile.price-api',
            },
        },
    }
    result = _request('POST', '/services', payload)
    service = result.get('service') if isinstance(result, dict) else None
    return service or result


def _trigger_deploy(service_id: str) -> dict:
    return _request('POST', f'/services/{service_id}/deploys', {'clearCache': 'do_not_clear'})


def main() -> int:
    owner_id = os.environ.get('RENDER_OWNER_ID', '').strip()
    if not owner_id:
        raise SystemExit('RENDER_OWNER_ID tanımlı değil.')

    existing = _find_service(owner_id)
    if existing:
        service_id = existing['id']
        print(f'Mevcut servis bulundu: {service_id}')
        deploy = _trigger_deploy(service_id)
        print(json.dumps(deploy, indent=2, ensure_ascii=False))
        url = existing.get('serviceDetails', {}).get('url') or existing.get('url')
        if url:
            print(f'\nAPI URL: {url.rstrip("/")}')
        return 0

    created = _create_service(owner_id)
    print('Servis oluşturuldu:')
    print(json.dumps(created, indent=2, ensure_ascii=False))
    url = created.get('serviceDetails', {}).get('url') or created.get('url')
    if url:
        print(f'\nAPI URL: {url.rstrip("/")}')
        print('\nGitHub repo → Settings → Secrets → PRICE_API_URL = yukarıdaki adres')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
