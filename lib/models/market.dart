import 'package:flutter/material.dart';

enum MarketId {
  migros,
  macrocenter,
  a101,
  bim,
  sok,
  carrefour,
  file,
  tarimKredi,
  hakmar,
  onur,
  happyCenter,
  metro,
  getir,
}

/// Market segmenti — kullanıcıya "neden pahalı/ucuz" bilgisini verir.
enum MarketSegment { indirim, ulusal, premium, yerel, toptan, hizli }

extension MarketSegmentX on MarketSegment {
  String get label => switch (this) {
        MarketSegment.indirim => 'İndirim',
        MarketSegment.ulusal => 'Ulusal zincir',
        MarketSegment.premium => 'Premium',
        MarketSegment.yerel => 'Yerel zincir',
        MarketSegment.toptan => 'Toptan',
        MarketSegment.hizli => 'Hızlı teslimat',
      };
}

class Market {
  const Market({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
    required this.segment,
    required this.site,
    this.noPriceReason,
  });

  final MarketId id;
  final String name;
  final String shortName;
  final Color color;
  final MarketSegment segment;

  /// Marketin kendi sitesi.
  final String site;

  /// Fiyatı okunamıyorsa nedeni; okunuyorsa `null`.
  ///
  /// Karşılaştırma yalnızca kendi sitesinde ürün fiyatı yayınlayan marketleri
  /// kapsar. Kalanlar için uygulama fiyat üretmez, sebebi kullanıcıya yazar.
  final String? noPriceReason;

  /// Fiyatı kendi sitesinden okunabiliyor mu?
  bool get publishesPrices => noPriceReason == null;

  static const all = <Market>[
    Market(
      id: MarketId.migros,
      name: 'Migros',
      shortName: 'MIG',
      color: Color(0xFFFF6600),
      segment: MarketSegment.ulusal,
      site: 'https://www.migros.com.tr/',
    ),
    Market(
      id: MarketId.macrocenter,
      name: 'Macrocenter',
      shortName: 'MACRO',
      color: Color(0xFF1B4D3E),
      segment: MarketSegment.premium,
      site: 'https://www.macrocenter.com.tr/',
    ),
    Market(
      id: MarketId.a101,
      name: 'A101',
      shortName: 'A101',
      color: Color(0xFF00ADEF),
      segment: MarketSegment.indirim,
      site: 'https://www.a101.com.tr/',
      noPriceReason: 'sitesi otomatik fiyat okumaya kapalı',
    ),
    Market(
      id: MarketId.bim,
      name: 'BİM',
      shortName: 'BİM',
      color: Color(0xFFE2001A),
      segment: MarketSegment.indirim,
      site: 'https://www.bim.com.tr/',
      noPriceReason: 'online satış yapmıyor, raf fiyatı yayınlamıyor',
    ),
    Market(
      id: MarketId.sok,
      name: 'Şok',
      shortName: 'ŞOK',
      color: Color(0xFFFFCC00),
      segment: MarketSegment.indirim,
      site: 'https://www.sokmarket.com.tr/',
    ),
    Market(
      id: MarketId.carrefour,
      name: 'CarrefourSA',
      shortName: 'CRF',
      color: Color(0xFF0055A5),
      segment: MarketSegment.ulusal,
      site: 'https://www.carrefoursa.com/',
      noPriceReason: 'sitesi otomatik fiyat okumaya kapalı',
    ),
    Market(
      id: MarketId.file,
      name: 'File',
      shortName: 'FILE',
      color: Color(0xFF6B2D8B),
      segment: MarketSegment.ulusal,
      site: 'https://www.file.com.tr/',
      noPriceReason: 'sitesinde ürün fiyatı yayınlanmıyor',
    ),
    Market(
      id: MarketId.tarimKredi,
      name: 'Tarım Kredi Market',
      shortName: 'TKM',
      color: Color(0xFF1F7A4D),
      segment: MarketSegment.indirim,
      site: 'https://www.tkkoop.com.tr/',
      noPriceReason: 'online mağazası yayında değil',
    ),
    Market(
      id: MarketId.hakmar,
      name: 'Hakmar Express',
      shortName: 'HAK',
      color: Color(0xFFD32F2F),
      segment: MarketSegment.indirim,
      site: 'https://www.hakmarexpress.com.tr/',
    ),
    Market(
      id: MarketId.onur,
      name: 'Onur Market',
      shortName: 'ONUR',
      color: Color(0xFFEF6C00),
      segment: MarketSegment.yerel,
      site: 'https://www.onurmarket.com/',
      noPriceReason: 'sitesinde ürün fiyatı yayınlanmıyor',
    ),
    Market(
      id: MarketId.happyCenter,
      name: 'Happy Center',
      shortName: 'HAPPY',
      color: Color(0xFF2E7D32),
      segment: MarketSegment.yerel,
      site: 'https://happycenter.com.tr/',
    ),
    Market(
      id: MarketId.metro,
      name: 'Metro Market',
      shortName: 'METRO',
      color: Color(0xFF283593),
      segment: MarketSegment.toptan,
      site: 'https://www.metro-tr.com/',
      noPriceReason: 'sitesi otomatik fiyat okumaya kapalı',
    ),
    Market(
      id: MarketId.getir,
      name: 'Getir Büyük',
      shortName: 'GETIR',
      color: Color(0xFF5D3EBC),
      segment: MarketSegment.hizli,
      site: 'https://getir.com/buyuk/',
      noPriceReason: 'sitesi otomatik fiyat okumaya kapalı',
    ),
  ];

  static Market byId(MarketId id) => all.firstWhere((m) => m.id == id);

  /// Fiyatı kendi sitesinden okunan marketler — karşılaştırma bunları kapsar.
  static List<Market> get priced =>
      all.where((m) => m.publishesPrices).toList();

  /// Fiyat yayınlamayan marketler; ekranda sebebiyle birlikte listelenir.
  static List<Market> get unpriced =>
      all.where((m) => !m.publishesPrices).toList();

  static List<Market> bySegment(MarketSegment segment) =>
      all.where((m) => m.segment == segment).toList();

  /// Kalıcı kayıtlardan okurken: tanınmayan / kaldırılmış market adı `null`.
  static MarketId? idFromName(String? name) {
    if (name == null) return null;
    for (final id in MarketId.values) {
      if (id.name == name) return id;
    }
    return null;
  }
}
