"""Market ürünlerini katalog satırlarına eşleştirir.

Kural: bir market ürünü ancak marka, çeşit **ve** gramaj katalogdaki satırla
birebir tutuyorsa o satırın fiyatı olabilir. Eşleşmeyen ürün fiyat üretmez;
uygulama o markette satırı fiyatsız gösterir.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

from .catalog import fold, slug, words


@dataclass(frozen=True)
class Offer:
    """Bir marketin kendi sitesinde yayınladığı ürün."""

    market: str
    name: str
    url: str
    price: float
    in_stock: bool = True
    # Market ürünü kilo/litre ile mi satıyor (raf fiyatı birim başına)?
    sold_by_weight: bool = False


# Ayrı fiyat sınıfı olan çeşitler: aynı satırda karşılaştırılamaz.
FORBID_ALWAYS = [
    'organik', 'glutensiz', 'vegan', 'laktozsuz', 'kampanya', 'promosyon',
    'hediyeli', 'al 3 ode', 'al 2 ode', 'ekonomik paket',
]

# Ambalajda yazan gramaj/hacim — kilo ile satılan üründe olmaması gerekir.
EXPLICIT_QUANTITY = re.compile(r'\b\d+([.,]\d+)?\s*(gr|g|ml|kg|lt|l)\b')


def _phrase_pattern(phrase: str) -> str:
    """Kelime sınırlı arama; Türkçe çekim ekleri serbest.

    "peynir" → "peyniri" eşleşir. Ama "-lı/-li/-lu/-lü" eki ürünü değiştirir:
    "maydanoz" araması "maydanozlu köfte"yi, "süt" araması "sütlü çikolata"yı
    bulmamalı.
    """
    if phrase.startswith(r'\b'):
        return phrase
    stem = fold(phrase)
    # Türkçe yumuşama: "çekirdek" → "çekirdeği", "ekmek" → "ekmeği".
    tail = '[kg]' if stem.endswith('k') else ''
    if tail:
        stem = stem[:-1]
    return rf'\b{re.escape(stem)}{tail}(?!l[iu])'


def matches_rule(rule: dict, offer: Offer, weight_based: bool) -> bool:
    """Ürün adı, tipin çeşit ve gramaj kuralını karşılıyor mu?"""
    name = ' '.join(words(offer.name))
    if not name:
        return False
    forbidden = list(rule['no'])
    forbidden += [
        word for word in FORBID_ALWAYS
        if not any(word in fold(term) for term in [rule['term'], *rule['must']])
    ]
    if any(re.search(_phrase_pattern(bad), name) for bad in forbidden):
        return False
    if not any(re.search(_phrase_pattern(good), name) for good in rule['must']):
        return False
    if weight_based:
        # Kilo ile satılan ürünün fiyatı kilo fiyatıdır. Ambalajlı ürün (500 g
        # paket) bu satıra giremez: kilo fiyatıyla karşılaştırılamaz.
        if re.search(r'\bkg\b', name):
            return True
        return offer.sold_by_weight and not EXPLICIT_QUANTITY.search(name)
    unit = rule['unit']
    return not unit or bool(re.search(unit, name))


def brand_tokens(brand: str) -> list[str]:
    return [t for t in slug(brand).split('-') if t]


def _brand_token_variants(brand: str) -> list[list[str]]:
    """Marka adının yazım varyantları.

    Kesme işareti markete göre değişiyor: "Nuh'un Ankara" bir sitede
    "Nuh'un Ankara", ötekinde "Nuhun Ankara" yazılır.
    """
    variants = [brand_tokens(brand)]
    if "'" in brand or '’' in brand:
        plain = brand_tokens(brand.replace("'", '').replace('’', ''))
        if plain and plain not in variants:
            variants.append(plain)
    return [v for v in variants if v]


def brand_position(name: str, brand: str) -> int:
    """Marka adı ürün adında kelime dizisi olarak geçiyorsa başlangıç sırası."""
    haystacks = (words(name), slug(name).split('-'))
    for tokens in _brand_token_variants(brand):
        for haystack in haystacks:
            for i in range(len(haystack) - len(tokens) + 1):
                if haystack[i:i + len(tokens)] == tokens:
                    return i
    return -1


def brand_of(name: str, brands: list[str]) -> str | None:
    """Ürün adındaki markayı bulur; en uzun marka adı kazanır.

    "Nuh'un Ankara Makarna" satırı hem `Ankara` hem `Nuh'un Ankara` markasına
    benzer; uzun ad seçilmezse fiyat yanlış markanın satırına yazılır.
    """
    hits = [b for b in brands if brand_position(name, b) >= 0]
    if not hits:
        return None
    return max(hits, key=lambda b: (len(brand_tokens(b)), len(slug(b))))


def pick(offers: list[Offer], rule: dict | None = None,
         brand: str | None = None) -> Offer | None:
    """Aynı satır için birden fazla ürün varsa hangisi?

    Marka seçilmişse aynı markanın en sade çeşidi alınır: kullanıcı markayı
    söylemiş, geriye çeşit kalmış.

    Marka seçilmemişse en ucuzu alınır. Markasız satırın sorusu "bu gramajı
    burada en aza kaça alırım?"; oraya marketin gurme çeşidini yazmak marketi
    haksız yere pahalı gösterir.
    """
    if not offers:
        return None
    if rule is None:
        return min(offers, key=lambda o: (not o.in_stock, o.price, len(o.name)))
    if brand is None:
        return min(offers, key=lambda o: (not o.in_stock, o.price, len(o.name)))
    return min(
        offers,
        key=lambda o: (
            not o.in_stock,
            len(variant_tokens(o.name, rule, brand)),
            o.price,
            len(o.name),
        ),
    )


# Çeşit imzasında ayırt edici olmayan kelimeler.
_NOISE = {
    'gr', 'g', 'kg', 'ml', 'lt', 'l', 'adet', 'li', 'lu', 'lik', 'luk', 'x',
    'paket', 'pk', 'pet', 'kutu', 'sise', 'ambalaj', 'no', 'urun', 'tane',
}


def variant_tokens(name: str, rule: dict, brand: str | None) -> frozenset[str]:
    """Ürünü çeşit olarak ayıran kelimeler (marka, tip ve birim çıkarılmış).

    "Colgate Max White ... 75 ml" ile "Colgate Üçlü Etki ... 75 ml" farklı
    çeşittir; imza sayesinde marketlerde aynı çeşidi seçebiliriz.
    """
    tokens = set(words(name))
    tokens -= _NOISE
    tokens -= {t for t in tokens if any(ch.isdigit() for ch in t)}
    for phrase in [rule['term'], *rule['must'], *(([brand] if brand else []))]:
        tokens -= set(words(phrase))
    return frozenset(tokens)


def choose_shared_variant(
    per_market: dict[str, list[Offer]],
    rule: dict,
    brand: str | None,
) -> dict[str, Offer]:
    """Marketlerde mümkün olduğunca aynı çeşidi seçer.

    Her market için önce en çok markette bulunan çeşit imzası denenir; o
    markette bu çeşit yoksa marketin en sade ve en ucuz eşleşmesi kullanılır.

    Marka verilmişse (aynı marka, aynı gramaj) fiyatlar birbirine yakın
    olmalıdır; aşırı sapan hücre yanlış çeşittir ve düşürülür.

    Markasız satırda çeşit hizalaması yapılmaz: kullanıcı marka söylemediği
    için her market kendi en uygun ürününü gösterir, kural her markette aynı
    olduğu sürece karşılaştırma dürüsttür.
    """
    if brand is None:
        return drop_overpriced({
            market: best
            for market, offers in per_market.items()
            if (best := pick(offers, rule, None)) is not None
        })
    signatures: dict[frozenset[str], set[str]] = {}
    for market, offers in per_market.items():
        for offer in offers:
            signature = variant_tokens(offer.name, rule, brand)
            signatures.setdefault(signature, set()).add(market)

    ranked = sorted(
        signatures.items(),
        key=lambda item: (-len(item[1]), len(item[0])),
    )
    shared = ranked[0][0] if ranked and len(ranked[0][1]) > 1 else None

    chosen: dict[str, Offer] = {}
    for market, offers in per_market.items():
        preferred = [
            o for o in offers
            if shared is not None
            and variant_tokens(o.name, rule, brand) == shared
        ]
        best = pick(preferred, rule, brand) or pick(offers, rule, brand)
        if best:
            chosen[market] = best
    return drop_outliers(chosen) if brand else chosen


# Aynı satırdaki fiyatlar bu kattan fazla açıldıysa ürünlerden biri aslında
# başka bir çeşittir; o hücre gösterilmez.
OUTLIER_FACTOR = 3.0


#: Markasız satırda medyanın bu katından pahalı hücre gösterilmez.
OVERPRICED_FACTOR = 3.5


def drop_overpriced(chosen: dict[str, Offer]) -> dict[str, Offer]:
    """Markasız satırda medyandan aşırı pahalı hücreleri çıkarır.

    Markasız satırda her market kendi en uygun ürününü gösterir, fiyat farkı
    da gerçektir: bir markette Selpak ucuz değildir. Ama ötekilerin katbekat
    üstünde bir tutar, çoğu zaman o markette sade ürünü bulamamış olmamızdır —
    "en ucuz 150 g cips" diye trüflü cips yazmak marketi haksız yere pahalı
    gösterir. Ucuz taraf kırpılmaz: gerçek bir ucuzluk, kullanıcının tam da
    aradığı şeydir.
    """
    if len(chosen) < 3:
        return chosen
    prices = sorted(offer.price for offer in chosen.values())
    median = prices[len(prices) // 2]
    return {
        market: offer
        for market, offer in chosen.items()
        if offer.price <= median * OVERPRICED_FACTOR
    }


def drop_outliers(chosen: dict[str, Offer]) -> dict[str, Offer]:
    """Satırın medyanından aşırı sapan market fiyatlarını çıkarır.

    Marka ve gramaj aynıysa fiyatlar birbirine yakın olmalı. Üç kat açılan
    hücre yanlış çeşit demektir; yanlış fiyat göstermek yerine satır o
    markette fiyatsız kalır. Karar için en az üç market gerekir.
    """
    if len(chosen) < 3:
        return chosen
    prices = sorted(offer.price for offer in chosen.values())
    median = prices[len(prices) // 2]
    return {
        market: offer
        for market, offer in chosen.items()
        if median / OUTLIER_FACTOR <= offer.price <= median * OUTLIER_FACTOR
    }
