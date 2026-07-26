"""Uygulamanın Dart kataloğunu okur.

Fiyat senkronu ürün tiplerini ve markaları tek kaynaktan alır: uygulamanın
kendi kataloğu. Böylece katalog büyüdükçe senkron da otomatik büyür.
"""

from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CATALOG_DART = REPO / 'lib' / 'data' / 'mock_catalog.dart'
BRANDS_DART = REPO / 'lib' / 'data' / 'brands.dart'

GENERIC_BRAND = 'Market markası'


def fold(text: str) -> str:
    """Türkçe karakterleri ASCII'ye katlar; sayı ve noktalama korunur.

    Dart tarafındaki `slugifyTurkish` ile aynı harf eşlemesini kullanır.
    """
    text = unicodedata.normalize('NFC', text).lower()
    table = {
        'ı': 'i', 'ğ': 'g', 'ü': 'u', 'ş': 's', 'ö': 'o', 'ç': 'c',
        'â': 'a', 'î': 'i', 'û': 'u', 'é': 'e', '\u0307': '',
    }
    return ''.join(table.get(ch, ch) for ch in text)


def slug(text: str) -> str:
    folded = re.sub(r'[^a-z0-9]+', '-', fold(text))
    return re.sub(r'^-|-$', '', re.sub(r'-+', '-', folded))


def words(text: str) -> list[str]:
    """Ürün adını eşleştirme için kelimelere ayırır (birim işaretleri kalır)."""
    cleaned = re.sub(r'[^a-z0-9,.%/ ]+', ' ', fold(text))
    return re.sub(r'\s+', ' ', cleaned).strip().split(' ')


@dataclass(frozen=True)
class ProductType:
    id: str
    name: str
    category: str
    unit: str


@dataclass(frozen=True)
class Catalog:
    types: list[ProductType]
    brands_by_category: dict[str, list[str]]

    def brands_for(self, type_: ProductType) -> list[str]:
        return self.brands_by_category.get(type_.category, [])


def load_catalog() -> Catalog:
    src = CATALOG_DART.read_text(encoding='utf-8')
    types = [
        ProductType(id=tid, name=name.replace(r"\'", "'"), category=cat, unit=unit)
        for tid, name, cat, unit in re.findall(
            r"id: '([a-z0-9-]+)',\s*\n\s*name: '((?:[^']|\\')*)',\s*\n"
            r"\s*category: '([^']*)',\s*\n\s*unit: '([^']*)'",
            src,
        )
    ]
    if not types:
        raise SystemExit(f'{CATALOG_DART} içinden ürün tipi okunamadı')

    brands_src = BRANDS_DART.read_text(encoding='utf-8')
    entries = re.findall(
        r"FoodBrand\(\s*id:\s*'[^']*',\s*name:\s*(\"[^\"]*\"|'[^']*'),"
        r"\s*categories:\s*\[(.*?)\]",
        brands_src,
        re.S,
    )
    by_category: dict[str, list[str]] = {}
    for raw_name, cats in entries:
        name = raw_name[1:-1]
        for category in re.findall(r"'([^']*)'", cats):
            by_category.setdefault(category, []).append(name)
    if not by_category:
        raise SystemExit(f'{BRANDS_DART} içinden marka okunamadı')
    return Catalog(types=types, brands_by_category=by_category)


def product_id(type_id: str, brand: str | None) -> str:
    """Dart tarafındaki `ProductType.withBrand(...).id` ile aynı kimlik."""
    key = slug(brand) if brand and brand.strip() else ''
    return f'{type_id}__{key or "markasiz"}'
