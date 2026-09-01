#!/usr/bin/env python3
"""Market Fiyatı eşleştirme birim testleri."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path
from unittest.mock import patch

TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))

from price_api.market_fiyati import (  # noqa: E402
    DepotPrice,
    MfProduct,
    match_product,
    search,
)


def _product(pid: str, title: str, brand: str, markets: dict[str, float]) -> MfProduct:
    depots = tuple(
        DepotPrice(
            market=market,
            depot_id=f'{market}-1',
            depot_name=market,
            price=price,
            product_name=title,
            index_time=None,
        )
        for market, price in markets.items()
    )
    return MfProduct(
        id=pid,
        title=title,
        brand=brand,
        volume='1 LT',
        category='Süt',
        image_url=None,
        depots=depots,
    )


class MatchTest(unittest.TestCase):
    def test_brand_and_name_win(self) -> None:
        hits = [
            _product('x', 'Pınar Süt 1 Lt', 'Pınar', {'migros': 70}),
            _product('y', 'İçim Süt 1 Lt', 'İçim', {'a101': 59.5, 'bim': 57}),
        ]
        chosen = match_product(hits, brand='İçim', name='Tam Yağlı Süt 1L')
        self.assertIsNotNone(chosen)
        self.assertEqual(chosen.id, 'y')
        self.assertEqual(chosen.cheapest_by_market()['bim'].price, 57)


class SearchParseTest(unittest.TestCase):
    @patch('price_api.market_fiyati._post')
    def test_search_parses_markets(self, post) -> None:
        post.return_value = {
            'content': [
                {
                    'id': '1T9S',
                    'title': 'İçim Süt 1 Lt',
                    'brand': 'İçim',
                    'refinedVolumeOrWeight': '1 LT',
                    'menu_category': 'Süt',
                    'productDepotInfoList': [
                        {
                            'marketAdi': 'a101',
                            'depotId': 'a101-1',
                            'depotName': 'A101',
                            'price': 59.5,
                        },
                        {
                            'marketAdi': 'bim',
                            'depotId': 'bim-1',
                            'depotName': 'BİM',
                            'price': 57.9,
                        },
                    ],
                },
            ],
        }
        products = search('icim sut')
        self.assertEqual(len(products), 1)
        by_market = products[0].cheapest_by_market()
        self.assertEqual(set(by_market), {'a101', 'bim'})
        self.assertEqual(by_market['a101'].price, 59.5)


if __name__ == '__main__':
    unittest.main()
