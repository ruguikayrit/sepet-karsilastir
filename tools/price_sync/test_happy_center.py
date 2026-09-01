#!/usr/bin/env python3
"""Happy Center genişletilmiş arama testi."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))

from price_sync.markets import ADAPTERS, FetchError  # noqa: E402


class HappyCenterSearchTest(unittest.TestCase):
    def test_html_search_returns_products(self) -> None:
        adapter = ADAPTERS['happyCenter']
        try:
            offers = adapter.search('sut', 1)
        except FetchError:
            self.skipTest('Happy Center ağ erişimi yok')
        self.assertGreater(len(offers), 5)
        self.assertTrue(all(o.url.startswith('https://happycenter.com.tr/') for o in offers))
        self.assertTrue(all(o.price and o.price > 0 for o in offers))


if __name__ == '__main__':
    unittest.main()
