"""Fiyat defterini canlı teklif için okur."""

from __future__ import annotations

from pathlib import Path

from price_sync.catalog import REPO
from price_sync.emit import read_dart
from price_sync.matching import Offer

DEFAULT_BOOK = REPO / 'lib' / 'data' / 'price_book.dart'


def load_book(path: Path = DEFAULT_BOOK) -> tuple[str, dict[str, dict[str, Offer]]]:
    return read_dart(path)
