#!/usr/bin/env python3
"""price_api önbellek birim testleri."""

from __future__ import annotations

import sys
import tempfile
import time
import unittest
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))

from price_api.cache import PageCache, SkuIndex  # noqa: E402
from price_sync.matching import Offer  # noqa: E402


class PageCacheTest(unittest.TestCase):
    def test_ttl_expires(self) -> None:
        cache = PageCache(ttl_seconds=0.05)
        cache.put('https://x.test/p', 'Title', 'body')
        self.assertIsNotNone(cache.get('https://x.test/p'))
        time.sleep(0.06)
        self.assertIsNone(cache.get('https://x.test/p'))


class SkuIndexTest(unittest.TestCase):
    def test_persist_roundtrip(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'sku_index.json'
            index = SkuIndex(path)
            offer = Offer(
                market='sok',
                name='Test Ürün 1 L',
                url='https://www.sokmarket.com.tr/test-p',
                price=99.9,
                in_stock=True,
            )
            index.put('sut-1l__test', 'sok', offer)
            reloaded = SkuIndex(path)
            record = reloaded.get('sut-1l__test', 'sok')
            self.assertIsNotNone(record)
            assert record is not None
            self.assertEqual(record.url, offer.url)
            self.assertEqual(record.price, offer.price)


if __name__ == '__main__':
    unittest.main()
