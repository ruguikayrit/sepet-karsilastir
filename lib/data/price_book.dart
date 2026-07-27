/// Marketlerin kendi sayfalarından okunan ürün fiyatları.
///
/// Bu dosya elle düzenlenmez; `tools/price_sync/sync.py` üretir.
///
/// Bir kayıt yalnızca üç bilgi birlikte doğrulandığında oluşur: marketin
/// sitesindeki ürün adı, o ürünün kendi sayfasının adresi ve o sayfadaki raf
/// fiyatı. Marka, çeşit ve gramaj katalogdaki satırla birebir aynıdır. Kaydı
/// olmayan satır uygulamada fiyatsız görünür; tahmin üretilmez.
///
/// Kaynak: Şok, Happy Center, Hakmar Express, Migros, Macrocenter
/// Çekim: 2026-07-26 · 504 ürün fiyatı, 212 satır
library;

import '../models/market.dart';

/// Bir marketin yayınladığı tek bir ürün.
class MarketOffer {
  const MarketOffer({
    required this.product,
    required this.url,
    required this.price,
    this.inStock = true,
  });

  /// Marketin sitesindeki tam ürün adı.
  final String product;

  /// Fiyatın okunduğu ürün sayfası — satıra dokununca bu adres açılır.
  final String url;

  /// Sayfadaki raf fiyatı (TRY).
  final double price;

  /// Çekim anında online satışta mıydı?
  final bool inStock;
}

/// Fiyat defterinin çekildiği gün (ISO 8601).
const priceBookFetchedAt = '2026-07-26';

/// Fiyatı kendi sitesinden okunabilen marketler.
const priceBookMarkets = <MarketId>[
  MarketId.sok,
  MarketId.happyCenter,
  MarketId.hakmar,
  MarketId.migros,
  MarketId.macrocenter,
];

/// `ürün tipi__marka` -> market -> o marketteki ürün ve fiyatı.
const priceBook = <String, Map<MarketId, MarketOffer>>{

  'aycicek-1l__evin': {
    MarketId.sok: MarketOffer(
      product: 'Evin Ayçiçek Yağı 1 L',
      url: 'https://www.sokmarket.com.tr/evin-aycicek-yagi-1-l-p-8747',
      price: 122.0,
    ),
  },
  'aycicek-1l__komili': {
    MarketId.happyCenter: MarketOffer(
      product: 'Komili Ayçiçek Yağı 1 lt',
      url: 'https://happycenter.com.tr/Komili_Y_aycicek_Yagi_1_Lt',
      price: 155.3,
    ),
  },
  'aycicek-1l__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Evin Ayçiçek Yağı 1 L',
      url: 'https://www.sokmarket.com.tr/evin-aycicek-yagi-1-l-p-8747',
      price: 122.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Happy Sweet Ayçiçek Yağı Pet 1 Lt',
      url: 'https://happycenter.com.tr/happy-sweet-aycicek-yagi-pet-1-lt',
      price: 127.55,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Yurda Ayçiçek Yağı 1 Lt',
      url: 'https://www.hakmarexpress.com.tr/yurda-aycicek-yagi-1-lt-1013681-p',
      price: 122.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Migros Ayçiçek Yağı 1 L',
      url: 'https://www.migros.com.tr/migros-aycicek-yagi-1-l-p-3eb726',
      price: 122.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Yudum Ayçiçek Yağı 1 L',
      url: 'https://www.macrocenter.com.tr/yudum-aycicek-yagi-1-l-p-3eb841',
      price: 214.95,
    ),
  },
  'aycicek-1l__yudum': {
    MarketId.happyCenter: MarketOffer(
      product: 'Yudum Ayçiçek Yağı 1 lt',
      url: 'https://happycenter.com.tr/Yudum_Y_aycicek_Yagi_1_Lt',
      price: 188.6,
    ),
    MarketId.migros: MarketOffer(
      product: 'Yudum Ayçiçekyağı 1 L',
      url: 'https://www.migros.com.tr/yudum-aycicekyagi-1-l-p-3eb841',
      price: 209.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Yudum Ayçiçek Yağı 1 L',
      url: 'https://www.macrocenter.com.tr/yudum-aycicek-yagi-1-l-p-3eb841',
      price: 214.95,
    ),
  },
  'aycicek-5l__evin': {
    MarketId.sok: MarketOffer(
      product: 'Evin Ayçiçek Yağı Pet 5 L',
      url: 'https://www.sokmarket.com.tr/evin-aycicek-yagi-pet-5-l-p-6486',
      price: 469.0,
    ),
  },
  'aycicek-5l__komili': {
    MarketId.happyCenter: MarketOffer(
      product: 'Komili Ayçiçek Yağı Kare Kubbeli Pet 5 lt.',
      url: 'https://happycenter.com.tr/komili-aycicek-yagi--kare-kubbeli-pet-5-lt-',
      price: 577.1,
    ),
    MarketId.migros: MarketOffer(
      product: 'Komili Ayçiçek Yağı 5 L',
      url: 'https://www.migros.com.tr/komili-aycicek-yagi-5-l-p-3eb6ee',
      price: 544.95,
    ),
  },
  'aycicek-5l__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Evin Ayçiçek Yağı Pet 5 L',
      url: 'https://www.sokmarket.com.tr/evin-aycicek-yagi-pet-5-l-p-6486',
      price: 469.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Sırma Ayçiçek Yağı Pet 5 Lt',
      url: 'https://happycenter.com.tr/r-yudum-aycicek-yagi-1-lt-pet-4-al-3-ode',
      price: 554.9,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Kırlangıç Ayçiçek Yağı Pet 5 Lt',
      url: 'https://www.hakmarexpress.com.tr/kirlangic-aycicek-yagi-pet-5-lt-1015500-p',
      price: 495.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Migros Ayçiçek Yağı 5 L',
      url: 'https://www.migros.com.tr/migros-aycicek-yagi-5-l-p-3ec039',
      price: 425.0,
    ),
  },
  'aycicek-5l__yudum': {
    MarketId.happyCenter: MarketOffer(
      product: 'Yudum Ayçiçek Yağı Pet 5 Lt',
      url: 'https://happycenter.com.tr/Yudum_Aycicek_Yagi_5_Lt_Pet',
      price: 588.2,
    ),
    MarketId.migros: MarketOffer(
      product: 'Yudum Ayçiçekyağı 5 L (Köşeli Pet)',
      url: 'https://www.migros.com.tr/yudum-aycicekyagi-5-l-koseli-pet-p-3eb707',
      price: 549.95,
    ),
  },
  'ayran-285__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mis Ayran Tam Yağlı 285 ml',
      url: 'https://www.sokmarket.com.tr/mis-ayran-tam-yagli-285-ml-p-6643',
      price: 13.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Sek Ayran 285 Ml',
      url: 'https://www.migros.com.tr/sek-ayran-285-ml-p-b04cf7',
      price: 21.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Sek Ayran 285 Ml',
      url: 'https://www.macrocenter.com.tr/sek-ayran-285-ml-p-b04cf7',
      price: 21.95,
    ),
  },
  'ayran-285__mis': {
    MarketId.sok: MarketOffer(
      product: 'Mis Ayran Tam Yağlı 285 ml',
      url: 'https://www.sokmarket.com.tr/mis-ayran-tam-yagli-285-ml-p-6643',
      price: 13.5,
    ),
  },
  'bebek-bezi__bebeland': {
    MarketId.sok: MarketOffer(
      product: 'Bebeland Kanallı Maxi Bebek Bezi 40 Adet',
      url: 'https://www.sokmarket.com.tr/bebeland-kanalli-maxi-bebek-bezi-40-adet-p-267697',
      price: 199.0,
    ),
  },
  'bebek-bezi__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Bebeland Kanallı Maxi Bebek Bezi 40 Adet',
      url: 'https://www.sokmarket.com.tr/bebeland-kanalli-maxi-bebek-bezi-40-adet-p-267697',
      price: 199.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Happy Bebek Bezi 5 Junior 40 Ad',
      url: 'https://happycenter.com.tr/happy-bebek-bezi-5-junior-40-ad',
      price: 210.8,
    ),
  },
  'bebek-bezi__sleepy': {
    MarketId.sok: MarketOffer(
      product: 'Sleepy Natural Double Soft Bebek Bezi Xl 40\'lı',
      url: 'https://www.sokmarket.com.tr/sleepy-natural-double-soft-bebek-bezi-xl-40-li-p-690890',
      price: 265.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Sleepy Çocuk Bezi Nat Klt 2 Li XL 40 Lı',
      url: 'https://happycenter.com.tr/sleepy-cocuk-bezi-nat-klt-2-li-xl-40-li',
      price: 188.7,
    ),
    MarketId.migros: MarketOffer(
      product: 'Sleepy Natural DB Soft Süper Külot Bez No 5 11-18 Kg 40\'lı',
      url: 'https://www.migros.com.tr/sleepy-natural-db-soft-super-kulot-bez-no-5-11-18-kg-40li-p-1da8fe6',
      price: 439.95,
    ),
  },
  'biber-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Çarliston Biber Kg',
      url: 'https://www.sokmarket.com.tr/carliston-biber-kg-p-34512',
      price: 139.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Biber Çarliston Kg',
      url: 'https://www.migros.com.tr/biber-carliston-kg-p-1ac0638',
      price: 133.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Biber Çarliston Kg',
      url: 'https://www.macrocenter.com.tr/biber-carliston-kg-p-1ac2646',
      price: 129.95,
    ),
  },
  'biskuvi-102__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Karmen Çikolatalı Sütlü Bisküvi 102 g',
      url: 'https://www.sokmarket.com.tr/karmen-cikolatali-sutlu-biskuvi-102-g-p-3723',
      price: 65.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Fiorella Sütlü Çikolatalı Bisküvi 102 G',
      url: 'https://www.macrocenter.com.tr/fiorella-sutlu-cikolatali-biskuvi-102-g-p-6b0b55',
      price: 97.5,
    ),
  },
  'bulasik-1500__bingo': {
    MarketId.sok: MarketOffer(
      product: 'Bingo Elde Bulaşık Deterjanı Limon 1500 Ml',
      url: 'https://www.sokmarket.com.tr/bingo-elde-bulasik-deterjani-limon-1500-ml-p-479491',
      price: 199.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Bingo Elde Bulaşık Deterjanı Limon 1500 Ml',
      url: 'https://www.migros.com.tr/bingo-elde-bulasik-deterjani-limon-1500-ml-p-1d313d7',
      price: 229.95,
    ),
  },
  'bulasik-1500__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Bingo Elde Bulaşık Deterjanı Limon 1500 Ml',
      url: 'https://www.sokmarket.com.tr/bingo-elde-bulasik-deterjani-limon-1500-ml-p-479491',
      price: 199.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Fairy Sıvı Bulaşık Deterjanı Limon 1500 ml',
      url: 'https://happycenter.com.tr/fairy-sivi-bulasik-deterjani-limon-1500-ml',
      price: 196.4,
    ),
  },
  'bulgur-1kg__anadolu-mutfagi': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Mutfağı Köftelik Bulgur 1 kg',
      url: 'https://www.sokmarket.com.tr/anadolu-mutfagi-koftelik-bulgur-1-kg-p-7644',
      price: 34.0,
    ),
  },
  'bulgur-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Mutfağı Köftelik Bulgur 1 kg',
      url: 'https://www.sokmarket.com.tr/anadolu-mutfagi-koftelik-bulgur-1-kg-p-7644',
      price: 34.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Happy Sweet Köftelik Bulgur 1 kg',
      url: 'https://happycenter.com.tr/Happy_Sweet_1000_Gr_Bkl_Bulgur_Koftelik__',
      price: 55.4,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Rençber Köftelik İnce Bulgur 1 Kg',
      url: 'https://www.hakmarexpress.com.tr/rencber-koftelik-ince-bulgur-1-kg-1000311-p',
      price: 34.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Duru Köftelik Bulgur 1 Kg',
      url: 'https://www.migros.com.tr/duru-koftelik-bulgur-1-kg-p-10a182',
      price: 49.67,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Duru Koftelik Bulgur 1000 G',
      url: 'https://www.macrocenter.com.tr/duru-koftelik-bulgur-1000-g-p-10a182',
      price: 70.95,
    ),
  },
  'bulgur-1kg__reis': {
    MarketId.happyCenter: MarketOffer(
      product: 'Reis Konya Köftelik Bulgur 1 kg',
      url: 'https://happycenter.com.tr/Reis_1000_Gr_Bulgur_Koftelik_Konya',
      price: 77.6,
    ),
    MarketId.migros: MarketOffer(
      product: 'Reis Köftelik Bulgur 1 Kg',
      url: 'https://www.migros.com.tr/reis-koftelik-bulgur-1-kg-p-107acf',
      price: 79.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Reis Köftelik Bulgur 1 Kg',
      url: 'https://www.macrocenter.com.tr/reis-koftelik-bulgur-1-kg-p-107acf',
      price: 79.95,
    ),
  },
  'bulgur-1kg__torku': {
    MarketId.migros: MarketOffer(
      product: 'Torku Köftelik Bulgur 1 Kg',
      url: 'https://www.migros.com.tr/torku-koftelik-bulgur-1-kg-p-10a1aa',
      price: 61.95,
    ),
  },
  'bulgur-1kg__yayla': {
    MarketId.migros: MarketOffer(
      product: 'Yayla Köftelik Bulgur 1 Kg',
      url: 'https://www.migros.com.tr/yayla-koftelik-bulgur-1-kg-p-107eb5',
      price: 49.95,
    ),
  },
  'cay-1000__caykur': {
    MarketId.sok: MarketOffer(
      product: 'Çaykur Rize Turist Çay 1000 g',
      url: 'https://www.sokmarket.com.tr/caykur-rize-turist-cay-1000-g-p-7545',
      price: 365.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Çaykur Rize Turist Çay 1000 gr',
      url: 'https://happycenter.com.tr/Caykur_1000_Gr_Cay_Rize',
      price: 420.6,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Çaykur Tiryaki Çayı Siyah Çay 1000 Gr',
      url: 'https://www.hakmarexpress.com.tr/caykur-tiryaki-cayi-siyah-cay-1000-gr-1000229-p',
      price: 356.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Çaykur Rize Turist Çay 1 Kg',
      url: 'https://www.migros.com.tr/caykur-rize-turist-cay-1-kg-p-2f7987',
      price: 399.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Çaykur Rize Turist Çay 1000 G',
      url: 'https://www.macrocenter.com.tr/caykur-rize-turist-cay-1000-g-p-2f7987',
      price: 407.95,
    ),
  },
  'cay-1000__dogus': {
    MarketId.sok: MarketOffer(
      product: 'Doğuş Çay Siyah 1 kg',
      url: 'https://www.sokmarket.com.tr/dogus-cay-siyah-1-kg-p-5134',
      price: 325.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Doğuş Siyah Çay 1000 Gr',
      url: 'https://happycenter.com.tr/Dogus_1000_Gr_Cay_Filiz_Siyah',
      price: 366.2,
    ),
    MarketId.migros: MarketOffer(
      product: 'Doğuş Siyah Çay 1 Kg',
      url: 'https://www.migros.com.tr/dogus-siyah-cay-1-kg-p-2f7ae2',
      price: 339.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Doğuş Siyah Çay 1000 g',
      url: 'https://www.macrocenter.com.tr/dogus-siyah-cay-1000-g-p-2f7ae2',
      price: 346.95,
    ),
  },
  'cay-1000__lipton': {
    MarketId.sok: MarketOffer(
      product: 'Lipton Yellow Label Çay 1000 g',
      url: 'https://www.sokmarket.com.tr/lipton-yellow-label-cay-1000-g-p-5132',
      price: 299.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Lipton Dökme Çay Doğu Karadeniz 1000 gr',
      url: 'https://happycenter.com.tr/Lipton_1000_Gr_Cay_Siyah_D_karadeniz',
      price: 366.2,
    ),
    MarketId.migros: MarketOffer(
      product: 'Lipton Yellow Label Çay 1 Kg',
      url: 'https://www.migros.com.tr/lipton-yellow-label-cay-1-kg-p-2f79f2',
      price: 279.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Lipton Doğu Karadeniz Dökme Çay 1000 G',
      url: 'https://www.macrocenter.com.tr/lipton-dogu-karadeniz-dokme-cay-1000-g-p-2f79f3',
      price: 382.95,
    ),
  },
  'cay-1000__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Deren Harman Çay 1 kg',
      url: 'https://www.sokmarket.com.tr/deren-harman-cay-1-kg-p-8786',
      price: 219.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Karali Premium Filiz Çay 1000 Gr',
      url: 'https://happycenter.com.tr/karali-premium-filiz-cay-1000-gr',
      price: 188.6,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Herdem Özel Harman Çay 1000 Gr',
      url: 'https://www.hakmarexpress.com.tr/herdem-ozel-harman-cay-1000-gr-1003566-p',
      price: 219.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Doğuş Rize Çay 1000 G',
      url: 'https://www.macrocenter.com.tr/dogus-rize-cay-1000-g-p-2f7ae3',
      price: 326.95,
    ),
  },
  'cay-1000__ofcay': {
    MarketId.hakmar: MarketOffer(
      product: 'Ofçay Tiryaki Dökme Siyah Çay 1000 Gr',
      url: 'https://www.hakmarexpress.com.tr/ofcay-tiryaki-dokme-siyah-cay-1000-gr-1000268-p',
      price: 265.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Ofçay Arhavi Çay 1 Kg',
      url: 'https://www.migros.com.tr/ofcay-arhavi-cay-1-kg-p-2f74b0',
      price: 334.95,
    ),
  },
  'cay-500__caykur': {
    MarketId.sok: MarketOffer(
      product: 'Çaykur Çay Çiçeği 500 g',
      url: 'https://www.sokmarket.com.tr/caykur-cay-cicegi-500-g-p-48713',
      price: 209.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Çaykur Çay Çiçeği 500 gr',
      url: 'https://happycenter.com.tr/Caykur_500_Gr_Caycicegi',
      price: 244.1,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Çaykur Kamelya Çayı Siyah Çay 500 Gr',
      url: 'https://www.hakmarexpress.com.tr/caykur-kamelya-cayi-siyah-cay-500-gr-1018352-p',
      price: 189.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Çaykur Çay Çiçeği 500 G',
      url: 'https://www.migros.com.tr/caykur-cay-cicegi-500-g-p-2f798e',
      price: 204.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Çaykur Çay Çiçeği 500 G',
      url: 'https://www.macrocenter.com.tr/caykur-cay-cicegi-500-g-p-2f798e',
      price: 204.95,
    ),
  },
  'cay-500__dogus': {
    MarketId.happyCenter: MarketOffer(
      product: 'Doğuş Siyah Çay 500 Gr',
      url: 'https://happycenter.com.tr/Dogus_500_Gr_Cay_Filiz_Siyah',
      price: 199.7,
    ),
    MarketId.migros: MarketOffer(
      product: 'Doğuş Karadeniz Export Çay 500 G',
      url: 'https://www.migros.com.tr/dogus-karadeniz-export-cay-500-g-p-2f7ab4',
      price: 244.95,
    ),
  },
  'cay-500__lipton': {
    MarketId.sok: MarketOffer(
      product: 'Lipton Yellow Label Çay 500 g',
      url: 'https://www.sokmarket.com.tr/lipton-yellow-label-cay-500-g-p-48654',
      price: 159.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Lipton Yellow Label Dökme Çay Pouch 500 gr',
      url: 'https://happycenter.com.tr/Lipton_500_Gr_Cay_Yellow_Label_Pouch_',
      price: 199.7,
    ),
    MarketId.migros: MarketOffer(
      product: 'Lipton Doğu Karadeniz Çayı 500 G',
      url: 'https://www.migros.com.tr/lipton-dogu-karadeniz-cayi-500-g-p-2f79f4',
      price: 229.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Lipton Yellow Label Çay Dökme 500 G',
      url: 'https://www.macrocenter.com.tr/lipton-yellow-label-cay-dokme-500-g-p-2f79eb',
      price: 279.95,
    ),
  },
  'cay-500__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Lipton Yellow Label Çay 500 g',
      url: 'https://www.sokmarket.com.tr/lipton-yellow-label-cay-500-g-p-48654',
      price: 159.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Efor Harman Siyah Çay 500 G',
      url: 'https://www.macrocenter.com.tr/efor-harman-siyah-cay-500-g-p-2f7498',
      price: 129.95,
    ),
  },
  'cay-500__ofcay': {
    MarketId.migros: MarketOffer(
      product: 'Ofçay Binbirdem Harman Çayı 500 G',
      url: 'https://www.migros.com.tr/ofcay-binbirdem-harman-cayi-500-g-p-2f9539',
      price: 74.95,
    ),
  },
  'cikolata-100__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Karmen Bol Sütlü Çikolata 100 g',
      url: 'https://www.sokmarket.com.tr/karmen-bol-sutlu-cikolata-100-g-p-449049',
      price: 64.9,
    ),
    MarketId.migros: MarketOffer(
      product: 'Schogetten Sütlü Çikolata 100 G',
      url: 'https://www.migros.com.tr/schogetten-sutlu-cikolata-100-g-p-6b6f28',
      price: 179.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Schogetten Sütlü Çikolata 100 G',
      url: 'https://www.macrocenter.com.tr/schogetten-sutlu-cikolata-100-g-p-6b6f28',
      price: 188.95,
    ),
  },
  'cips-150__amigo': {
    MarketId.sok: MarketOffer(
      product: 'Amigo Düz Sade Patates Cipsi 150 g',
      url: 'https://www.sokmarket.com.tr/amigo-duz-sade-patates-cipsi-150-g-p-4767',
      price: 46.5,
    ),
  },
  'cips-150__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Amigo Düz Sade Patates Cipsi 150 g',
      url: 'https://www.sokmarket.com.tr/amigo-duz-sade-patates-cipsi-150-g-p-4767',
      price: 46.5,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Toledo Klasik Patates Cipsi 150 Gr',
      url: 'https://www.hakmarexpress.com.tr/toledo-klasik-patates-cipsi-150-gr-1031823-p',
      price: 45.0,
    ),
  },
  'cop-torbasi__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Koroplast Güçlü Orta 15 Li Çöp Torbası',
      url: 'https://happycenter.com.tr/Koroplast_Cop_Dogada_Cozunur__Torbasi_Orta_',
      price: 99.8,
    ),
  },
  'deterjan-1-5kg__alo': {
    MarketId.migros: MarketOffer(
      product: 'Alo 1,5 Kg Kar Çiçeği Ferahlığı Beyazlar ve Renkliler Aquapudra Toz Deterjan',
      url: 'https://www.migros.com.tr/alo-15-kg-kar-cicegi-ferahligi-beyazlar-ve-renkliler-aquapudra-toz-deterjan-p-1cbbbcb',
      price: 139.95,
    ),
  },
  'deterjan-1-5kg__ariel': {
    MarketId.happyCenter: MarketOffer(
      product: 'Ariel Toz Çamaşır Deterjanı Dağ Esintisi 1,5 kg',
      url: 'https://happycenter.com.tr/Ariel_Matik_1_5_Kg_Dag_Esintisi',
      price: 199.7,
    ),
    MarketId.migros: MarketOffer(
      product: 'Ariel Dağ Esintisi 1,5 Kg AquaPudra Toz Çamaşır Deterjanı',
      url: 'https://www.migros.com.tr/ariel-dag-esintisi-15-kg-aquapudra-toz-camasir-deterjani-p-1cbbd07',
      price: 192.95,
    ),
  },
  'deterjan-1-5kg__bingo': {
    MarketId.happyCenter: MarketOffer(
      product: 'Bingo Matik Çamaşır Deterjanı Renkli 1,5 kg',
      url: 'https://happycenter.com.tr/Bingo_Matik_1500_Gr_lovely_Parfumlu',
      price: 166.4,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Bingo Toz Çamaşır Deterjanı Renkliler 1500 Gr',
      url: 'https://www.hakmarexpress.com.tr/bingo-toz-camasir-deterjani-renkliler-1500-gr-1001972-p',
      price: 139.0,
    ),
  },
  'deterjan-1-5kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Omo Matik Color Toz Deterjan 1.5 Kg',
      url: 'https://www.sokmarket.com.tr/omo-matik-color-toz-deterjan-1-5-kg-p-5366',
      price: 235.0,
    ),
  },
  'deterjan-1-5kg__omo': {
    MarketId.sok: MarketOffer(
      product: 'Omo Matik Color Toz Deterjan 1.5 Kg',
      url: 'https://www.sokmarket.com.tr/omo-matik-color-toz-deterjan-1-5-kg-p-5366',
      price: 235.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Omo Matik Active Fresh Toz Çamaşır Deterjanı 1,5 kg',
      url: 'https://happycenter.com.tr/Omo_Matik_1500_Gr_Active_Fresh',
      price: 177.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Omo Active Fresh Beyazlar Toz Deterjanı 1.5 Kg',
      url: 'https://www.migros.com.tr/omo-active-fresh-beyazlar-toz-deterjani-15-kg-p-1cbbd22',
      price: 235.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Omo Active Fresh Beyazlar Toz Deterjan 10 Yıkama 1.5 Kg',
      url: 'https://www.macrocenter.com.tr/omo-active-fresh-beyazlar-toz-deterjan-10-yikama-15-kg-p-1cbbd22',
      price: 247.95,
    ),
  },
  'deterjan-1-5kg__persil': {
    MarketId.happyCenter: MarketOffer(
      product: 'Persil Expert Çamaşır Deterjanı Gül Büyüsü 1,5 kg',
      url: 'https://happycenter.com.tr/Persil_Gold_1500_Gr_Gulun_Buyusu',
      price: 221.9,
    ),
  },
  'dis-macunu__colgate': {
    MarketId.sok: MarketOffer(
      product: 'Colgate Üçlü Etki Diş Macunu 75 ml',
      url: 'https://www.sokmarket.com.tr/colgate-uclu-etki-dis-macunu-75-ml-p-3949',
      price: 99.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Colgate Max White Kalıcı Beyazlık Diş Macunu75 Ml',
      url: 'https://happycenter.com.tr/Colgate_Dis_Mac_100ml_Max_Beyazlik_',
      price: 188.55,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Colgate Max White Kalıcı Beyazlık Beyazlatıcı Diş Macunu 75 ml',
      url: 'https://www.hakmarexpress.com.tr/colgate-max-white-kalici-beyazlik-beyazlatici-dis-macunu-75-ml-1013953-p',
      price: 147.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Colgate Max White Kalıcı Beyazlık Diş Macunu 75 Ml',
      url: 'https://www.migros.com.tr/colgate-max-white-kalici-beyazlik-dis-macunu-75-ml-p-2070937',
      price: 152.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Colgate Max White Kalıcı Beyazlık Diş Macunu 75 Ml',
      url: 'https://www.macrocenter.com.tr/colgate-max-white-kalici-beyazlik-dis-macunu-75-ml-p-2070937',
      price: 150.0,
    ),
  },
  'dis-macunu__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Colgate Üçlü Etki Diş Macunu 75 ml',
      url: 'https://www.sokmarket.com.tr/colgate-uclu-etki-dis-macunu-75-ml-p-3949',
      price: 99.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Signal Diş Macunu Anında Beyazlık 75 ml',
      url: 'https://happycenter.com.tr/Signal_Dis_Mac_75ml_White_Now',
      price: 155.3,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Signal White System Diş Macunu 75 Ml',
      url: 'https://www.hakmarexpress.com.tr/signal-white-system-dis-macunu-75-ml-1003375-p',
      price: 114.9,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Signal White System Diş Macunu 75 Ml',
      url: 'https://www.macrocenter.com.tr/signal-white-system-dis-macunu-75-ml-p-2070680',
      price: 140.0,
    ),
  },
  'domates-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Salkım Domates Kg',
      url: 'https://www.sokmarket.com.tr/salkim-domates-kg-p-32771',
      price: 45.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Domates Salkım Kg',
      url: 'https://www.migros.com.tr/domates-salkim-kg-p-1ac92d8',
      price: 61.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Domates Salkım Kg',
      url: 'https://www.macrocenter.com.tr/domates-salkim-kg-p-1ac9b3f',
      price: 69.95,
    ),
  },
  'dondurma-500__algida': {
    MarketId.sok: MarketOffer(
      product: 'Algida Maraş Usulü Sade Dondurma 500 ml',
      url: 'https://www.sokmarket.com.tr/algida-maras-usulu-sade-dondurma-500-ml-p-8891',
      price: 200.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Algida Dond Inh. Almido Dondurma 500 Ml',
      url: 'https://happycenter.com.tr/algida-dond-inh--almido-dondurma-500-ml',
      price: 150.0,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Algida Maraş Sade Çikolata Dondurma 500 Ml',
      url: 'https://www.hakmarexpress.com.tr/algida-maras-sade-cikolata-dondurma-500-ml-1009645-p',
      price: 200.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Algida Usta Bol Kaymak Dondurma 500 Ml',
      url: 'https://www.migros.com.tr/algida-usta-bol-kaymak-dondurma-500-ml-p-b08bf6',
      price: 225.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Algida Usta Bol Kaymak Dondurma 500 Ml',
      url: 'https://www.macrocenter.com.tr/algida-usta-bol-kaymak-dondurma-500-ml-p-b08bf6',
      price: 225.0,
    ),
  },
  'dondurma-500__markasiz': {
    MarketId.hakmar: MarketOffer(
      product: 'Golf Maraşım Sade Dondurma 500 Ml',
      url: 'https://www.hakmarexpress.com.tr/golf-marasim-sade-dondurma-500-ml-1009742-p',
      price: 225.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Kechy Gurme Dondurma Doğa 500 Ml',
      url: 'https://www.macrocenter.com.tr/kechy-gurme-dondurma-doga-500-ml-p-b09af9',
      price: 458.95,
    ),
  },
  'dus-jeli__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Cleana Duş Jeli Orkide 500ml',
      url: 'https://www.sokmarket.com.tr/cleana-dus-jeli-orkide-500ml-p-550305',
      price: 58.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Palmolive Duş Jeli 500Ml So Relaxed',
      url: 'https://happycenter.com.tr/Palmolive_Dus_Jeli_500ml_At_anti_Stress',
      price: 299.55,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Miself Ocean Fresh Duş Jeli 500 Ml',
      url: 'https://www.macrocenter.com.tr/miself-ocean-fresh-dus-jeli-500-ml-p-21c5204',
      price: 100.0,
    ),
  },
  'ekmek-beyaz__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Odun Ekmek',
      url: 'https://www.sokmarket.com.tr/odun-ekmek-p-5643',
      price: 17.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Etc.Lkp Ekmek Normal 250 Gr',
      url: 'https://happycenter.com.tr/etc-lkp-ekmek-normal-200-gr',
      price: 14.45,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Tazepan Ekmek Çok Tahıllı 430 Gr',
      url: 'https://www.hakmarexpress.com.tr/tazepan-ekmek-cok-tahilli-430-gr-1026992-p',
      price: 69.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Sofra Ekmek Adet',
      url: 'https://www.migros.com.tr/sofra-ekmek-adet-p-4e2000',
      price: 20.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Tandır Lavaş Ekmek 200 G',
      url: 'https://www.macrocenter.com.tr/tandir-lavas-ekmek-200-g-p-4d2d86',
      price: 50.95,
    ),
  },
  'ekmek-beyaz__uno': {
    MarketId.sok: MarketOffer(
      product: 'Uno Anadolu Kepekli Ekmek 400 g',
      url: 'https://www.sokmarket.com.tr/uno-anadolu-kepekli-ekmek-400-g-p-5328',
      price: 39.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Uno Fırından Çavdarlı Ekmek 450 Gr',
      url: 'https://happycenter.com.tr/Uno_450_Gr_Firindan_Tam_Cavdarli_Ekmek',
      price: 99.9,
    ),
    MarketId.migros: MarketOffer(
      product: 'Uno Sandviç Ekmeği 5\'li 325 G',
      url: 'https://www.migros.com.tr/uno-sandvic-ekmegi-5li-325-g-p-4d1d97',
      price: 80.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Uno Sandviç Ekmeği 5\'li 325 G',
      url: 'https://www.macrocenter.com.tr/uno-sandvic-ekmegi-5li-325-g-p-4d1d97',
      price: 80.0,
    ),
  },
  'ekmek-tam-bugday__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Ihe Tam Buğday Ekmek 400 gr',
      url: 'https://happycenter.com.tr/Ihe_400_Gr_Tam_Bugday_Ekmek',
      price: 61.05,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'İhe Tam Buğday Ekmeği 400 g',
      url: 'https://www.macrocenter.com.tr/ihe-tam-bugday-ekmegi-400-g-p-4d18e3',
      price: 55.0,
    ),
  },
  'ekmek-tam-bugday__uno': {
    MarketId.happyCenter: MarketOffer(
      product: 'Uno Ekşi Mayalı Tam Buğday Ekmeği 450 Gr',
      url: 'https://happycenter.com.tr/Uno_450_Gr_Sofra_Yogun_Kepekli_Koy_Ekmek',
      price: 99.9,
    ),
    MarketId.migros: MarketOffer(
      product: 'Uno Ekşi Mayalı Tam Buğday Ekmek 450 G',
      url: 'https://www.migros.com.tr/uno-eksi-mayali-tam-bugday-ekmek-450-g-p-4d2a39',
      price: 90.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Uno Ekşi Mayalı Tam Buğday Ekmek 450 G',
      url: 'https://www.macrocenter.com.tr/uno-eksi-mayali-tam-bugday-ekmek-450-g-p-4d2a39',
      price: 90.0,
    ),
  },
  'filtre-kahve__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Lezzcafe Filtre Kahve 250 g',
      url: 'https://www.sokmarket.com.tr/lezzcafe-filtre-kahve-250-g-p-2970',
      price: 189.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Black Pearl Guatamala Fıltre Kahve 250 Gr',
      url: 'https://happycenter.com.tr/black-pearl-guatamala-filtre-kahve-250-gr',
      price: 138.65,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Tchibo Gold Selection Filtre Kahve 250 Gr',
      url: 'https://www.hakmarexpress.com.tr/tchibo-gold-selection-filtre-kahve-250-gr-1020662-p',
      price: 349.5,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Kahve Dünyası Filtre Kahve 250 G',
      url: 'https://www.macrocenter.com.tr/kahve-dunyasi-filtre-kahve-250-g-p-31223e',
      price: 279.95,
    ),
  },
  'filtre-kahve__mehmet-efendi': {
    MarketId.sok: MarketOffer(
      product: 'Mehmet Efendi Colombian Filtre Kahve 250 g',
      url: 'https://www.sokmarket.com.tr/mehmet-efendi-colombian-filtre-kahve-250-g-p-3601',
      price: 275.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Mehmet Efendi Colombian Filtre Kahve 250 Gr',
      url: 'https://happycenter.com.tr/mehmet-efendi-filtre-kahve-250-gr',
      price: 349.5,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Kurukahveci Mehmet Efendi Brazilian Filtre Kahve 250gr',
      url: 'https://www.macrocenter.com.tr/kurukahveci-mehmet-efendi-brazilian-filtre-kahve-250gr-p-31ed58',
      price: 269.95,
    ),
  },
  'findik-ici__amigo': {
    MarketId.sok: MarketOffer(
      product: 'Amigo Fındık İçi 150 g',
      url: 'https://www.sokmarket.com.tr/amigo-findik-ici-150-g-p-8465',
      price: 188.0,
    ),
  },
  'findik-ici__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Amigo Dalından Çiğ Fındık 150 g',
      url: 'https://www.sokmarket.com.tr/amigo-dalindan-cig-findik-150-g-p-8085',
      price: 153.0,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Çerezim Kavrulmuş Fındık İçi 150 Gr',
      url: 'https://www.hakmarexpress.com.tr/cerezim-kavrulmus-findik-ici-150-gr-1000464-p',
      price: 188.0,
    ),
  },
  'gofret-350__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Peki Muzlu Gofret 350 g',
      url: 'https://www.sokmarket.com.tr/peki-muzlu-gofret-350-g-p-3725',
      price: 49.95,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Çıtırgı Muz Aromalı Gofret 350G',
      url: 'https://www.hakmarexpress.com.tr/citirgi-muz-aromali-gofret-350g-1031777-p',
      price: 49.5,
    ),
  },
  'havuc-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Havuç Kg',
      url: 'https://www.sokmarket.com.tr/havuc-kg-p-36260',
      price: 69.9,
    ),
    MarketId.migros: MarketOffer(
      product: 'Havuç Beypazarı Paket Kg',
      url: 'https://www.migros.com.tr/havuc-beypazari-paket-kg-p-1ad36f9',
      price: 82.5,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Havuç Kg',
      url: 'https://www.macrocenter.com.tr/havuc-kg-p-1ad3718',
      price: 89.95,
    ),
  },
  'kabak-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Kabak Sakız Kg',
      url: 'https://www.sokmarket.com.tr/kabak-sakiz-kg-p-36315',
      price: 69.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Kabak Sakız Kg',
      url: 'https://www.migros.com.tr/kabak-sakiz-kg-p-1adb000',
      price: 72.5,
    ),
  },
  'kahve-100__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Yemeneli Türk Kahvesi 100 g',
      url: 'https://www.sokmarket.com.tr/yemeneli-turk-kahvesi-100-g-p-8744',
      price: 69.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Hakkı Efendi Türk Kahvesi 100 Gr',
      url: 'https://happycenter.com.tr/hakki-efendi-turk-kahvesi-100-gr',
      price: 55.4,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Halis Efendi Türk Kahvesi 100 Gr',
      url: 'https://www.hakmarexpress.com.tr/halis-efendi-turk-kahvesi-100-gr-1028689-p',
      price: 69.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Tchibo Türk Kahvesi 100 G',
      url: 'https://www.migros.com.tr/tchibo-turk-kahvesi-100-g-p-31032b',
      price: 96.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Kurukahveci Mehmet Efendi Türk Kahvesi 100 G',
      url: 'https://www.macrocenter.com.tr/kurukahveci-mehmet-efendi-turk-kahvesi-100-g-p-310151',
      price: 99.95,
    ),
  },
  'kahve-100__mehmet-efendi': {
    MarketId.sok: MarketOffer(
      product: 'Kurukahveci Mehmet Efendi Türk Kahvesi 100 g',
      url: 'https://www.sokmarket.com.tr/kurukahveci-mehmet-efendi-turk-kahvesi-100-g-p-4743',
      price: 97.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Mehmet Efendi Türk Kahvesi 100 Gr',
      url: 'https://happycenter.com.tr/Mehmet_Efendi_100_Gr_Turk_Kahvesi',
      price: 108.2,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Kurukahveci Mehmet Efendi Türk Kahvesi 100 Gr',
      url: 'https://www.hakmarexpress.com.tr/kurukahveci-mehmet-efendi-turk-kahvesi-100-gr-1000193-p',
      price: 97.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Kurukahveci Mehmet Efendi Türk Kahvesi 100 G',
      url: 'https://www.migros.com.tr/kurukahveci-mehmet-efendi-turk-kahvesi-100-g-p-310151',
      price: 69.5,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Kurukahveci Mehmet Efendi Türk Kahvesi 100 G',
      url: 'https://www.macrocenter.com.tr/kurukahveci-mehmet-efendi-turk-kahvesi-100-g-p-310151',
      price: 99.95,
    ),
  },
  'kasar-500__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mis Tam Yağlı Kaşar Peyniri 500 g',
      url: 'https://www.sokmarket.com.tr/mis-tam-yagli-kasar-peyniri-500-g-p-8768',
      price: 227.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Muratbey Taze Kaşar Peyniri 500 Gr',
      url: 'https://happycenter.com.tr/Muratbey_Taze_Kasar_400_Gr',
      price: 360.65,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Gündoğdu Taze Kaşar 500 G',
      url: 'https://www.macrocenter.com.tr/gundogdu-taze-kasar-500-g-p-9a1dab',
      price: 379.95,
    ),
  },
  'kasar-500__mis': {
    MarketId.sok: MarketOffer(
      product: 'Mis Tam Yağlı Kaşar Peyniri 500 g',
      url: 'https://www.sokmarket.com.tr/mis-tam-yagli-kasar-peyniri-500-g-p-8768',
      price: 227.0,
    ),
  },
  'kasar-500__muratbey': {
    MarketId.happyCenter: MarketOffer(
      product: 'Muratbey Taze Kaşar Peyniri 500 Gr',
      url: 'https://happycenter.com.tr/Muratbey_Taze_Kasar_400_Gr',
      price: 360.65,
    ),
    MarketId.migros: MarketOffer(
      product: 'Muratbey Tam Yağlı Taze Kaşar 500 G',
      url: 'https://www.migros.com.tr/muratbey-tam-yagli-taze-kasar-500-g-p-9a241a',
      price: 499.9,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Muratbey Tam Yağlı Taze Kaşar 500 G',
      url: 'https://www.macrocenter.com.tr/muratbey-tam-yagli-taze-kasar-500-g-p-9a241a',
      price: 509.95,
    ),
  },
  'kasar-500__sutas': {
    MarketId.sok: MarketOffer(
      product: 'Sütaş Kaşar Peyniri 500 g',
      url: 'https://www.sokmarket.com.tr/sutas-kasar-peyniri-500-g-p-4684',
      price: 299.0,
    ),
  },
  'kek-162__eti': {
    MarketId.migros: MarketOffer(
      product: 'Eti Popkek Mini Bitter Çikolatalı Kek 162 G',
      url: 'https://www.migros.com.tr/eti-popkek-mini-bitter-cikolatali-kek-162-g-p-4dec1d',
      price: 59.5,
    ),
  },
  'kek-162__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Ülker 8 Kek Orman Meyveli 162 g',
      url: 'https://www.sokmarket.com.tr/ulker-8-kek-orman-meyveli-162-g-p-489910',
      price: 49.95,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Ülker 8 Kek Mini Muzlu Kek 162 Gr',
      url: 'https://happycenter.com.tr/ulker-8-kek-mini-muzlu-kek-162-gr',
      price: 48.8,
    ),
  },
  'kek-162__solen': {
    MarketId.sok: MarketOffer(
      product: 'Şölen Luppo Vişneli Brownie Kek 162 g',
      url: 'https://www.sokmarket.com.tr/solen-luppo-visneli-brownie-kek-162-g-p-766029',
      price: 49.95,
    ),
  },
  'kek-162__ulker': {
    MarketId.sok: MarketOffer(
      product: 'Ülker 8 Kek Orman Meyveli 162 g',
      url: 'https://www.sokmarket.com.tr/ulker-8-kek-orman-meyveli-162-g-p-489910',
      price: 49.95,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Ülker 8 Kek Mini Muzlu Kek 162 Gr',
      url: 'https://happycenter.com.tr/ulker-8-kek-mini-muzlu-kek-162-gr',
      price: 48.8,
    ),
    MarketId.migros: MarketOffer(
      product: 'Ülker 8 Kek Orman Meyveli Mini Kekler 162 G',
      url: 'https://www.migros.com.tr/ulker-8-kek-orman-meyveli-mini-kekler-162-g-p-6b49c6',
      price: 59.9,
    ),
  },
  'ketcap-500__bizim-vatan': {
    MarketId.sok: MarketOffer(
      product: 'Ketçap Bizim Vatan 500 g',
      url: 'https://www.sokmarket.com.tr/ketcap-bizim-vatan-500-g-p-8444',
      price: 39.9,
    ),
  },
  'ketcap-500__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Ketçap Bizim Vatan 500 g',
      url: 'https://www.sokmarket.com.tr/ketcap-bizim-vatan-500-g-p-8444',
      price: 39.9,
    ),
  },
  'kiyma-400__lezzetlim': {
    MarketId.sok: MarketOffer(
      product: 'Lezzetlim Dana Kıyma 400 g',
      url: 'https://www.sokmarket.com.tr/lezzetlim-dana-kiyma-400-g-p-5443',
      price: 330.0,
    ),
  },
  'kiyma-400__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Lezzetlim Dana Kıyma 400 g',
      url: 'https://www.sokmarket.com.tr/lezzetlim-dana-kiyma-400-g-p-5443',
      price: 330.0,
    ),
  },
  'kofte-500__aytac': {
    MarketId.sok: MarketOffer(
      product: 'Aytaç Dondurulmuş Dana Maydanozlu Köfte 500 g',
      url: 'https://www.sokmarket.com.tr/aytac-dondurulmus-dana-maydanozlu-kofte-500-g-p-636121',
      price: 399.0,
    ),
  },
  'kola-1l__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Sarıyer Kola Sekersız 1 Lt',
      url: 'https://happycenter.com.tr/sariyer-kola-sekersiz-1-lt',
      price: 42.7,
    ),
    MarketId.migros: MarketOffer(
      product: 'Pepsi Kola 1 L',
      url: 'https://www.migros.com.tr/pepsi-kola-1-l-p-7a3c30',
      price: 58.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Pepsi Zero Sugar Kola Pet 1 L',
      url: 'https://www.macrocenter.com.tr/pepsi-zero-sugar-kola-pet-1-l-p-7a3c3a',
      price: 57.0,
    ),
  },
  'kola-2-5l__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Sarıyer Kola 2.5 Lt',
      url: 'https://happycenter.com.tr/sariyer-kola-2-5-lt',
      price: 76.55,
    ),
    MarketId.migros: MarketOffer(
      product: 'Pepsi Kola 2,5 L',
      url: 'https://www.migros.com.tr/pepsi-kola-25-l-p-7a3fb4',
      price: 81.0,
    ),
  },
  'konserve-fasulye__bizim-vatan': {
    MarketId.sok: MarketOffer(
      product: 'Haşlanmış Kuru Fasulye Bizim Vatan 800 g',
      url: 'https://www.sokmarket.com.tr/haslanmis-kuru-fasulye-bizim-vatan-800-g-p-5612',
      price: 40.5,
    ),
  },
  'konserve-fasulye__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Haşlanmış Kuru Fasulye Bizim Vatan 800 g',
      url: 'https://www.sokmarket.com.tr/haslanmis-kuru-fasulye-bizim-vatan-800-g-p-5612',
      price: 40.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Yurt Haşlanmış Fasulye Konservesi 800 gr',
      url: 'https://happycenter.com.tr/Yurt_11_Haslanmis_Fasulye_Tnk',
      price: 74.3,
    ),
    MarketId.migros: MarketOffer(
      product: 'Tamek Haşlanmış Fasulye 800 G',
      url: 'https://www.migros.com.tr/tamek-haslanmis-fasulye-800-g-p-89d37a',
      price: 87.95,
    ),
  },
  'konserve-misir__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Super Fresh Mısır Teneke 3x200 gr',
      url: 'https://happycenter.com.tr/S_fresh_220_Gr_X_3_Misir_Tnk',
      price: 93.7,
    ),
    MarketId.migros: MarketOffer(
      product: 'Superfresh Mısır 3x200 G',
      url: 'https://www.migros.com.tr/superfresh-misir-3x200-g-p-89e07c',
      price: 90.95,
    ),
  },
  'konserve-misir__superfresh': {
    MarketId.migros: MarketOffer(
      product: 'Superfresh Mısır 3x200 G',
      url: 'https://www.migros.com.tr/superfresh-misir-3x200-g-p-89e07c',
      price: 90.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Superfresh Mısır 3X200 G',
      url: 'https://www.macrocenter.com.tr/superfresh-misir-3x200-g-p-89e07c',
      price: 110.95,
    ),
  },
  'kraker-82__ulker': {
    MarketId.sok: MarketOffer(
      product: 'Ülker Çiziviç Kraker Peynirli Sandviç 82 g',
      url: 'https://www.sokmarket.com.tr/ulker-cizivic-kraker-peynirli-sandvic-82-g-p-7091',
      price: 22.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Ülker Çiziviç Peynirli Sandviç Kraker 82 gr',
      url: 'https://happycenter.com.tr/Ulker_B__95_4_Cizivic_Peynir_Kremali_90_Gr',
      price: 24.95,
    ),
    MarketId.migros: MarketOffer(
      product: 'Ülker Çiziviç Peynirli Kremalı Sandviç Kraker 82 G',
      url: 'https://www.migros.com.tr/ulker-cizivicpeynirlikremali-sandvickraker82-g-p-6b127c',
      price: 22.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Ülker Çiziviç Peynirli Kremalı Sandviç Kraker 82 G',
      url: 'https://www.macrocenter.com.tr/ulker-cizivicpeynirlikremali-sandvickraker82-g-p-6b127c',
      price: 22.95,
    ),
  },
  'labne-400__icim': {
    MarketId.sok: MarketOffer(
      product: 'İçim Labne Peyniri 400 g',
      url: 'https://www.sokmarket.com.tr/icim-labne-peyniri-400-g-p-8449',
      price: 149.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'İçim Labne 400 gr',
      url: 'https://happycenter.com.tr/Icim_Labne_500_Gr',
      price: 183.05,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'İçim Labne 400 Gr',
      url: 'https://www.hakmarexpress.com.tr/icim-labne-400-gr-1008784-p',
      price: 145.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'İçim Labne Peynir 400 G',
      url: 'https://www.migros.com.tr/icim-labne-peynir-400-g-p-9d3242',
      price: 156.75,
    ),
  },
  'labne-400__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mis Labne Peyniri 400 g',
      url: 'https://www.sokmarket.com.tr/mis-labne-peyniri-400-g-p-5592',
      price: 112.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Pınar Labne Peynir 400 gr',
      url: 'https://happycenter.com.tr/Pinar_Labne_400_Gr',
      price: 149.75,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'İçim Labne 400 Gr',
      url: 'https://www.hakmarexpress.com.tr/icim-labne-400-gr-1008784-p',
      price: 145.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Torku Labne 400 G',
      url: 'https://www.migros.com.tr/torku-labne-400-g-p-9d324f',
      price: 154.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Pınar Labne Peynir 400 G',
      url: 'https://www.macrocenter.com.tr/pinar-labne-peynir-400-g-p-9dedd4',
      price: 169.5,
    ),
  },
  'labne-400__mis': {
    MarketId.sok: MarketOffer(
      product: 'Mis Labne Peyniri 400 g',
      url: 'https://www.sokmarket.com.tr/mis-labne-peyniri-400-g-p-5592',
      price: 112.0,
    ),
  },
  'labne-400__pinar': {
    MarketId.happyCenter: MarketOffer(
      product: 'Pınar Labne Peynir 400 gr',
      url: 'https://happycenter.com.tr/Pinar_Labne_400_Gr',
      price: 149.75,
    ),
    MarketId.migros: MarketOffer(
      product: 'Pınar Labne 400 G',
      url: 'https://www.migros.com.tr/pinar-labne-400-g-p-9dedd4',
      price: 165.9,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Pınar Labne Peynir 400 G',
      url: 'https://www.macrocenter.com.tr/pinar-labne-peynir-400-g-p-9dedd4',
      price: 169.5,
    ),
  },
  'labne-400__sutas': {
    MarketId.happyCenter: MarketOffer(
      product: 'Sütaş Labne Peynir 400 gr',
      url: 'https://happycenter.com.tr/Sutas_Labne_Peynir_400_Gr',
      price: 177.5,
    ),
  },
  'maden-6x__beypazari': {
    MarketId.happyCenter: MarketOffer(
      product: 'Beypazarı Maden Suyu 6x 200 Ml',
      url: 'https://happycenter.com.tr/r-beypazari-maden-suyu-6x200-ml',
      price: 77.6,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Beypazarı Doğal Maden Suyu 6x200 Ml',
      url: 'https://www.hakmarexpress.com.tr/beypazari-dogal-maden-suyu-6x200-ml-1004185-p',
      price: 69.5,
    ),
  },
  'maden-6x__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Sırma Maden Suyu 6x200 Ml',
      url: 'https://happycenter.com.tr/Sirma_6x200ml_Maden_Suyu',
      price: 55.4,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Beypazarı Doğal Maden Suyu 6x200 Ml',
      url: 'https://www.hakmarexpress.com.tr/beypazari-dogal-maden-suyu-6x200-ml-1004185-p',
      price: 69.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Sırma Maden Suyu 6 x 200 Ml',
      url: 'https://www.migros.com.tr/sirma-maden-suyu-6-x-200-ml-p-7ab1c4',
      price: 82.5,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Kızılay Maden Suyu Afyon 6 x 200 Ml',
      url: 'https://www.macrocenter.com.tr/kizilay-maden-suyu-afyon-6-x-200-ml-p-7ab0cf',
      price: 66.7,
    ),
  },
  'maden-6x__saka': {
    MarketId.happyCenter: MarketOffer(
      product: 'Saka Maden Suyu 6X200 Ml.',
      url: 'https://happycenter.com.tr/saka-6-x-200-ml-maden-suyu',
      price: 63.2,
    ),
    MarketId.migros: MarketOffer(
      product: 'Saka Doğal Maden Suyu 6 x 200 Ml',
      url: 'https://www.migros.com.tr/saka-dogal-maden-suyu-6-x-200-ml-p-7aae79',
      price: 71.5,
    ),
  },
  'maden-6x__uludag': {
    MarketId.happyCenter: MarketOffer(
      product: 'ULUDAG 6X200 ML MADEN SUYU SADE CAM',
      url: 'https://happycenter.com.tr/Uludag_6_X_200_Ml_Maden_Suyu_Cam',
      price: 77.6,
    ),
    MarketId.migros: MarketOffer(
      product: 'Uludağ Doğal Maden Suyu 6X200 Ml',
      url: 'https://www.migros.com.tr/uludag-dogal-maden-suyu-6x200-ml-p-7ab0ca',
      price: 66.0,
    ),
  },
  'makarna-500__ankara': {
    MarketId.happyCenter: MarketOffer(
      product: 'Ankara 500 Gr Makarna Buğday Spagetti',
      url: 'https://happycenter.com.tr/Ankara_500_Gr_Makarna_T_bugday_Spagetti',
      price: 41.0,
    ),
  },
  'makarna-500__barilla': {
    MarketId.sok: MarketOffer(
      product: 'Barilla Spagetti Makarna No:5 500 g',
      url: 'https://www.sokmarket.com.tr/barilla-spagetti-makarna-no-5-500-g-p-8013',
      price: 47.95,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Barilla Makarna Spagetti 500 gr',
      url: 'https://happycenter.com.tr/Barilla_500_Gr_Makarna_Spagetti',
      price: 66.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Barilla Spagetti (Spaghetti) Makarna No.5 500 G',
      url: 'https://www.migros.com.tr/barilla-spagetti-spaghetti-makarna-no5-500-g-p-4cc1c8',
      price: 44.96,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Barilla Linguine Yassı Spagetti 500 G',
      url: 'https://www.macrocenter.com.tr/barilla-linguine-yassi-spagetti-500-g-p-4cc1cd',
      price: 61.5,
    ),
  },
  'makarna-500__filiz': {
    MarketId.sok: MarketOffer(
      product: 'Filiz Makarna Spaghetti 500 g',
      url: 'https://www.sokmarket.com.tr/filiz-makarna-spaghetti-500-g-p-4845',
      price: 33.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Filiz Spagetti Makarna 500 gr',
      url: 'https://happycenter.com.tr/Filiz_500_Gr_Makarna_Spagetti',
      price: 37.65,
    ),
    MarketId.migros: MarketOffer(
      product: 'Filiz Yassı Spagetti Makarna 500 G',
      url: 'https://www.migros.com.tr/filiz-yassi-spagetti-makarna-500-g-p-4cc1db',
      price: 34.95,
    ),
  },
  'makarna-500__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Piyale Spagetti 500 g',
      url: 'https://www.sokmarket.com.tr/piyale-spagetti-500-g-p-5641',
      price: 17.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Oba Spagetti Makarna 500 gr',
      url: 'https://happycenter.com.tr/Oba_500_Gr_Makarna_Spagetti',
      price: 17.7,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Tat Makarna Spagetti 500 gr',
      url: 'https://www.hakmarexpress.com.tr/tat-makarna-spagetti-500-gr-1007815-p',
      price: 17.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Barilla Spagetti (Spaghetti) Makarna No.5 500 G',
      url: 'https://www.migros.com.tr/barilla-spagetti-spaghetti-makarna-no5-500-g-p-4cc1c8',
      price: 44.96,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Makaroma Spaghetti 500 G',
      url: 'https://www.macrocenter.com.tr/makaroma-spaghetti-500-g-p-4cc189',
      price: 48.95,
    ),
  },
  'makarna-500__nuh-un-ankara': {
    MarketId.sok: MarketOffer(
      product: 'Nuh\'un Ankara Vitaminli Spaghetti 500 g',
      url: 'https://www.sokmarket.com.tr/nuh-un-ankara-vitaminli-spaghetti-500-g-p-8012',
      price: 33.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Nuhun Ankara Spaghetti Makarna 500 gr',
      url: 'https://happycenter.com.tr/D_ankara_500_Gr_Spagetti_Makarna',
      price: 37.65,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Nuh\'un Ankara Makarna Spaghetti 500 Gr',
      url: 'https://www.hakmarexpress.com.tr/nuhun-ankara-makarna-spaghetti-500-gr-1004569-p',
      price: 33.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Nuh\'Un Ankara Spagetti Makarna 500 G',
      url: 'https://www.migros.com.tr/nuhun-ankara-spagetti-makarna-500-g-p-4cc140',
      price: 34.95,
    ),
  },
  'makarna-500__pastavilla': {
    MarketId.happyCenter: MarketOffer(
      product: 'Pastavilla Spaghetti Makarna 500 gr',
      url: 'https://happycenter.com.tr/Pastavilla_500_Gr_Spaghetti_Makarna',
      price: 33.2,
    ),
  },
  'makarna-500__piyale': {
    MarketId.sok: MarketOffer(
      product: 'Piyale Spagetti 500 g',
      url: 'https://www.sokmarket.com.tr/piyale-spagetti-500-g-p-5641',
      price: 17.0,
    ),
  },
  'makarna-penne__ankara': {
    MarketId.happyCenter: MarketOffer(
      product: 'Ankara 500 Gr Makarna Buğday Penne',
      url: 'https://happycenter.com.tr/Ankara_500_Gr_Makarna_T_bugday_Penne',
      price: 41.0,
    ),
  },
  'makarna-penne__barilla': {
    MarketId.sok: MarketOffer(
      product: 'Barilla Penne Rigate (Kalem) Makarna 500 g',
      url: 'https://www.sokmarket.com.tr/barilla-penne-rigate-kalem-makarna-500-g-p-4733',
      price: 47.95,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Barilla Penne Rigate Kalem Makarna 500 gr',
      url: 'https://happycenter.com.tr/Barilla_500_Gr_Makarna_Kalem_penne_Rigate',
      price: 66.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Barilla Penne Rigate (Kalem) Makarna 500 G',
      url: 'https://www.migros.com.tr/barilla-penne-rigate-kalem-makarna-500-g-p-4cc1c6',
      price: 44.96,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Barilla Penne Rigate Kalem 500 G',
      url: 'https://www.macrocenter.com.tr/barilla-penne-rigate-kalem-500-g-p-4cc1c6',
      price: 61.5,
    ),
  },
  'makarna-penne__filiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Filiz Kalem Makarna 500 gr',
      url: 'https://happycenter.com.tr/Filiz_500_Gr_Makarna_Kisa_Kalem',
      price: 37.65,
    ),
    MarketId.migros: MarketOffer(
      product: 'Filiz Kalem Makarna 500 G',
      url: 'https://www.migros.com.tr/filiz-kalem-makarna-500-g-p-4cc1d8',
      price: 34.95,
    ),
  },
  'makarna-penne__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Barilla Penne Rigate (Kalem) Makarna 500 g',
      url: 'https://www.sokmarket.com.tr/barilla-penne-rigate-kalem-makarna-500-g-p-4733',
      price: 47.95,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Nuhun Ankara Penne Makarna 500 gr',
      url: 'https://happycenter.com.tr/Ankara_500_Gr_Penne_Makarna',
      price: 37.65,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Mutlu Penne Makarna 500 gr',
      url: 'https://www.hakmarexpress.com.tr/mutlu-penne-makarna-500-gr-1034254-p',
      price: 26.75,
    ),
    MarketId.migros: MarketOffer(
      product: 'Mutlu Penne Makarna 500 G',
      url: 'https://www.migros.com.tr/mutlu-penne-makarna-500-g-p-4cc104',
      price: 19.75,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Makaroma Penne Rigate 500 G',
      url: 'https://www.macrocenter.com.tr/makaroma-penne-rigate-500-g-p-4cc18a',
      price: 48.95,
    ),
  },
  'makarna-penne__nuh-un-ankara': {
    MarketId.happyCenter: MarketOffer(
      product: 'Nuhun Ankara Penne Makarna 500 gr',
      url: 'https://happycenter.com.tr/Ankara_500_Gr_Penne_Makarna',
      price: 37.65,
    ),
    MarketId.migros: MarketOffer(
      product: 'Nuhun Ankara Tam Buğday Penne Makarna 500 G',
      url: 'https://www.migros.com.tr/nuhun-ankara-tam-bugday-penne-makarna-500-g-p-4ce5ee',
      price: 47.95,
    ),
  },
  'makarna-penne__pastavilla': {
    MarketId.happyCenter: MarketOffer(
      product: 'Pastavilla Kalem Makarna 500 gr',
      url: 'https://happycenter.com.tr/Pastavilla_500_Gr_Kalem_Makarna',
      price: 33.2,
    ),
  },
  'maydanoz__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Maydanoz',
      url: 'https://happycenter.com.tr/maydanoz-demet',
      price: 15.65,
    ),
    MarketId.migros: MarketOffer(
      product: 'Maydanoz Adet',
      url: 'https://www.migros.com.tr/maydanoz-adet-p-1af36a9',
      price: 30.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Maydanoz Adet',
      url: 'https://www.macrocenter.com.tr/maydanoz-adet-p-1af36a9',
      price: 32.95,
    ),
  },
  'mayonez-430__bizim-vatan': {
    MarketId.sok: MarketOffer(
      product: 'Mayonez Bizim Vatan 430 g',
      url: 'https://www.sokmarket.com.tr/mayonez-bizim-vatan-430-g-p-8372',
      price: 79.0,
    ),
  },
  'mayonez-430__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mayonez Bizim Vatan 430 g',
      url: 'https://www.sokmarket.com.tr/mayonez-bizim-vatan-430-g-p-8372',
      price: 79.0,
    ),
  },
  'mercimek-1kg__anadolu-mutfagi': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Mutfağı Kırmızı Mercimek 1000 g',
      url: 'https://www.sokmarket.com.tr/anadolu-mutfagi-kirmizi-mercimek-1000-g-p-9055',
      price: 49.5,
    ),
  },
  'mercimek-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Mutfağı Kırmızı Mercimek 1000 g',
      url: 'https://www.sokmarket.com.tr/anadolu-mutfagi-kirmizi-mercimek-1000-g-p-9055',
      price: 49.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Göze İthal Kırmızı Mercimek 1 kg',
      url: 'https://happycenter.com.tr/goze-kirmizi-mercimek-1-kg',
      price: 77.6,
    ),
    MarketId.migros: MarketOffer(
      product: 'Yayla Kırmızı Mercimek 1 Kg',
      url: 'https://www.migros.com.tr/yayla-kirmizi-mercimek-1-kg-p-103416',
      price: 109.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Yayla Kırmızı Mercimek 1 Kg',
      url: 'https://www.macrocenter.com.tr/yayla-kirmizi-mercimek-1-kg-p-103416',
      price: 109.95,
    ),
  },
  'mercimek-1kg__reis': {
    MarketId.migros: MarketOffer(
      product: 'Reis Kırmızı Mercimek 1 Kg',
      url: 'https://www.migros.com.tr/reis-kirmizi-mercimek-1-kg-p-102cb8',
      price: 179.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Reis Kırmızı Mercimek 1 Kg',
      url: 'https://www.macrocenter.com.tr/reis-kirmizi-mercimek-1-kg-p-102cb8',
      price: 269.95,
    ),
  },
  'mercimek-1kg__yayla': {
    MarketId.migros: MarketOffer(
      product: 'Yayla Kırmızı Mercimek 1 Kg',
      url: 'https://www.migros.com.tr/yayla-kirmizi-mercimek-1-kg-p-103416',
      price: 109.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Yayla Kırmızı Mercimek 1 Kg',
      url: 'https://www.macrocenter.com.tr/yayla-kirmizi-mercimek-1-kg-p-103416',
      price: 109.95,
    ),
  },
  'meyvesuyu-1l__lipton': {
    MarketId.macrocenter: MarketOffer(
      product: 'Lipton Ice Tea Mango Ve Exotic Meyve Pet 1 L',
      url: 'https://www.macrocenter.com.tr/lipton-ice-tea-mango-ve-exotic-meyve-pet-1-l-p-7ae98b',
      price: 59.0,
    ),
  },
  'meyvesuyu-1l__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mis Meyve Nektarı Kayısı 1 L',
      url: 'https://www.sokmarket.com.tr/mis-meyve-nektari-kayisi-1-l-p-7209',
      price: 50.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Cappy Meyve Suyu Pulpy Şeftali Pet 1 lt',
      url: 'https://happycenter.com.tr/Cappy_1_Lt_Pet_M_suyu_Meyve_Tanem_Seftali',
      price: 72.05,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Cappy Meyve Suyu Pulpy Portakallı 1 Lt',
      url: 'https://www.hakmarexpress.com.tr/cappy-meyve-suyu-pulpy-portakalli-1-lt-1007840-p',
      price: 75.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Tamek Karışık Meyve Nektarı 1 Lt',
      url: 'https://www.macrocenter.com.tr/tamek-karisik-meyve-nektari-1-lt-p-7af8eb',
      price: 64.99,
    ),
  },
  'meyvesuyu-1l__meysu': {
    MarketId.sok: MarketOffer(
      product: 'Meysu % 100 Karışık Meyve Suyu 1 L',
      url: 'https://www.sokmarket.com.tr/meysu-100-karisik-meyve-suyu-1-l-p-138',
      price: 69.9,
    ),
  },
  'meyvesuyu-1l__mis': {
    MarketId.sok: MarketOffer(
      product: 'Mis Meyve Nektarı Kayısı 1 L',
      url: 'https://www.sokmarket.com.tr/mis-meyve-nektari-kayisi-1-l-p-7209',
      price: 50.0,
    ),
  },
  'misir-gevregi__kellogg-s': {
    MarketId.sok: MarketOffer(
      product: 'Kellogg\'s Coco Pops Kakaolu Mısır ve Buğday Gevreği 450 g',
      url: 'https://www.sokmarket.com.tr/kellogg-s-coco-pops-kakaolu-misir-ve-bugday-gevregi-450-g-p-8899',
      price: 198.5,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Kelloggs Cocopops Çikolatalı Mısır ve Buğday Gevreği 450 Gr',
      url: 'https://www.hakmarexpress.com.tr/kelloggs-cocopops-cikolatali-misir-ve-bugday-gevregi-450-gr-1001998-p',
      price: 159.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Kellogg\'s Coco Pops Kakaolu Mısır ve Buğday Gevreği 450 G',
      url: 'https://www.migros.com.tr/kelloggs-coco-pops-kakaolu-misir-ve-bugday-gevregi-450-g-p-4dcaa3',
      price: 198.95,
    ),
  },
  'misir-gevregi__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Nestle G.Nesquık Mısır Gevreği 450 Gr %20 Bedava',
      url: 'https://happycenter.com.tr/nestle-450-gr-nesquik-misir-gevregi-2--si-50-indi',
      price: 130.9,
    ),
  },
  'muz-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Yerli Muz Kg',
      url: 'https://www.sokmarket.com.tr/yerli-muz-kg-p-33027',
      price: 94.9,
    ),
    MarketId.migros: MarketOffer(
      product: 'Muz İthal Kg',
      url: 'https://www.migros.com.tr/muz-ithal-kg-p-1a01f58',
      price: 113.5,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Muz İthal Kg',
      url: 'https://www.macrocenter.com.tr/muz-ithal-kg-p-1a0235b',
      price: 159.95,
    ),
  },
  'nohut-1kg__anadolu-mutfagi': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Mutfağı Nohut 1 kg',
      url: 'https://www.sokmarket.com.tr/anadolu-mutfagi-nohut-1-kg-p-9054',
      price: 62.5,
    ),
  },
  'nohut-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Mutfağı Nohut 1 kg',
      url: 'https://www.sokmarket.com.tr/anadolu-mutfagi-nohut-1-kg-p-9054',
      price: 62.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Happy Sweet Nohut 1 kg',
      url: 'https://happycenter.com.tr/Happy_Sweet_1000_Gr_Bkl_Nohut',
      price: 110.9,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Rençber Koçbaşı Nohut 1 Kg',
      url: 'https://www.hakmarexpress.com.tr/rencber-kocbasi-nohut-1-kg-1000316-p',
      price: 62.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Migros Nohut 1000 G',
      url: 'https://www.migros.com.tr/migros-nohut-1000-g-p-100579',
      price: 62.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Reis Koçbaşı Nohut 1 Kg',
      url: 'https://www.macrocenter.com.tr/reis-kocbasi-nohut-1-kg-p-fde92',
      price: 210.95,
    ),
  },
  'nohut-1kg__reis': {
    MarketId.happyCenter: MarketOffer(
      product: 'Reis Nevşehir Nohut 1 kg',
      url: 'https://happycenter.com.tr/Reis_1000_Gr_Nohut_Nevsehir_',
      price: 244.1,
    ),
    MarketId.migros: MarketOffer(
      product: 'Reis Koçbaşı Nohut 1 Kg',
      url: 'https://www.migros.com.tr/reis-kocbasi-nohut-1-kg-p-fde92',
      price: 206.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Reis Koçbaşı Nohut 1 Kg',
      url: 'https://www.macrocenter.com.tr/reis-kocbasi-nohut-1-kg-p-fde92',
      price: 210.95,
    ),
  },
  'nohut-1kg__yayla': {
    MarketId.migros: MarketOffer(
      product: 'Yayla Koçbaşı Nohut (İri Boy) 1 Kg',
      url: 'https://www.migros.com.tr/yayla-kocbasi-nohut-iri-boy-1-kg-p-100547',
      price: 134.95,
    ),
  },
  'patates-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Patates Kg',
      url: 'https://www.sokmarket.com.tr/patates-kg-p-35919',
      price: 39.5,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Patates File Kg',
      url: 'https://www.macrocenter.com.tr/patates-file-kg-p-1afc75d',
      price: 44.95,
    ),
  },
  'patlican-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Patlıcan Kemer Kg',
      url: 'https://www.sokmarket.com.tr/patlican-kemer-kg-p-36285',
      price: 59.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Patlıcan Kemer Kg',
      url: 'https://www.migros.com.tr/patlican-kemer-kg-p-1afde98',
      price: 49.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Patlıcan Kemer Kg',
      url: 'https://www.macrocenter.com.tr/patlican-kemer-kg-p-1aff645',
      price: 79.95,
    ),
  },
  'peynir-500__icim': {
    MarketId.happyCenter: MarketOffer(
      product: 'İçim Beyaz Peynir Tam Yağlı 500 gr',
      url: 'https://happycenter.com.tr/Icim_Tam_Yagli_Beyaz_Peynir_500_Gr',
      price: 210.8,
    ),
    MarketId.migros: MarketOffer(
      product: 'İçim Tam Yağlı Beyaz Peynir 500 G',
      url: 'https://www.migros.com.tr/icim-tam-yagli-beyaz-peynir-500-g-p-98d502',
      price: 197.95,
    ),
  },
  'peynir-500__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mis Tam Yağlı Beyaz Peynir 500 g',
      url: 'https://www.sokmarket.com.tr/mis-tam-yagli-beyaz-peynir-500-g-p-7382',
      price: 139.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Sütaş Beyaz Peynir Tam Yağlı 500 gr',
      url: 'https://happycenter.com.tr/Sutas_Tam_Yagli_Beyaz_Peynir_500_Gr',
      price: 199.7,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Güneşoğlu Sürbeni Beyaz Peynir 500 Gr',
      url: 'https://www.hakmarexpress.com.tr/gunesoglu-surbeni-beyaz-peynir-500-gr-1027267-p',
      price: 127.5,
    ),
  },
  'peynir-500__mis': {
    MarketId.sok: MarketOffer(
      product: 'Mis Tam Yağlı Beyaz Peynir 500 g',
      url: 'https://www.sokmarket.com.tr/mis-tam-yagli-beyaz-peynir-500-g-p-7382',
      price: 139.0,
    ),
  },
  'peynir-500__sutas': {
    MarketId.happyCenter: MarketOffer(
      product: 'Sütaş Beyaz Peynir Tam Yağlı 500 gr',
      url: 'https://happycenter.com.tr/Sutas_Tam_Yagli_Beyaz_Peynir_500_Gr',
      price: 199.7,
    ),
  },
  'peynir-500__tahsildaroglu': {
    MarketId.happyCenter: MarketOffer(
      product: 'Tahsildaroğlu Beyaz Peynir Klasik 500 gr',
      url: 'https://happycenter.com.tr/tahsildaroglu-beyaz-peynir-ezine-klasik-500-gr',
      price: 366.2,
    ),
    MarketId.migros: MarketOffer(
      product: 'Tahsildaroğlu Klasik İnek Beyaz Peyniri 500 G',
      url: 'https://www.migros.com.tr/tahsildaroglu-klasik-inek-beyaz-peyniri-500-g-p-98e1a1',
      price: 299.9,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Tahsildaroğlu Klasik İnek Beyaz Peyniri 500 G',
      url: 'https://www.macrocenter.com.tr/tahsildaroglu-klasik-inek-beyaz-peyniri-500-g-p-98e1a1',
      price: 409.95,
    ),
  },
  'pilic-but__banvit': {
    MarketId.macrocenter: MarketOffer(
      product: 'Banvit Piliç Kalçalı But Kg',
      url: 'https://www.macrocenter.com.tr/banvit-pilic-kalcali-but-kg-p-2be8453',
      price: 149.95,
    ),
  },
  'pilic-but__gedik': {
    MarketId.sok: MarketOffer(
      product: 'Gedik Piliç Kalçalı But Kg',
      url: 'https://www.sokmarket.com.tr/gedik-pilic-kalcali-but-kg-p-460899',
      price: 125.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Gedik Tabaklı Soslu Piliç But Şiş Kg',
      url: 'https://www.migros.com.tr/gedik-tabakli-soslu-pilic-but-sis-kg-p-c6a97c',
      price: 499.95,
    ),
  },
  'pirinc-1kg__anadolu-mutfagi': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Mutfağı Kırık Pirinç 1 kg',
      url: 'https://www.sokmarket.com.tr/anadolu-mutfagi-kirik-pirinc-1-kg-p-5789',
      price: 32.5,
    ),
  },
  'pirinc-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Mutfağı Kırık Pirinç 1 kg',
      url: 'https://www.sokmarket.com.tr/anadolu-mutfagi-kirik-pirinc-1-kg-p-5789',
      price: 32.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Happy Sweet Kırık Pirinç 1 kg',
      url: 'https://happycenter.com.tr/Happy_Sweet_1000_Gr_Bkl_Pirinc_Kirik',
      price: 44.3,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Rençber Kırık Pirinç 1 Kg',
      url: 'https://www.hakmarexpress.com.tr/rencber-kirik-pirinc-1-kg-1000344-p',
      price: 32.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Yayla Tane Tane Pirinç 1 Kg',
      url: 'https://www.migros.com.tr/yayla-tane-tane-pirinc-1-kg-p-f69eb',
      price: 129.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Yayla Zenginleştirilmiş Osmancık Pirinç 1 Kg',
      url: 'https://www.macrocenter.com.tr/yayla-zenginlestirilmis-osmancik-pirinc-1-kg-p-f8031',
      price: 134.95,
    ),
  },
  'pirinc-1kg__reis': {
    MarketId.happyCenter: MarketOffer(
      product: 'Reis Osmancık Pirinç 1 kg',
      url: 'https://happycenter.com.tr/Reis_1000_Gr_Pirinc_Osmancik',
      price: 199.7,
    ),
    MarketId.migros: MarketOffer(
      product: 'Reis Osmancık Pirinç 1 Kg',
      url: 'https://www.migros.com.tr/reis-osmancik-pirinc-1-kg-p-f6a3a',
      price: 179.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Reis Osmancık Pirinç 1 Kg',
      url: 'https://www.macrocenter.com.tr/reis-osmancik-pirinc-1-kg-p-f6a3a',
      price: 189.95,
    ),
  },
  'pirinc-1kg__yayla': {
    MarketId.migros: MarketOffer(
      product: 'Yayla Zenginleştirilmiş Baldo Pirinç 1 Kg',
      url: 'https://www.migros.com.tr/yayla-zenginlestirilmis-baldo-pirinc-1-kg-p-f8037',
      price: 164.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Yayla Zenginleştirilmiş Osmancık Pirinç 1 Kg',
      url: 'https://www.macrocenter.com.tr/yayla-zenginlestirilmis-osmancik-pirinc-1-kg-p-f8031',
      price: 134.95,
    ),
  },
  'recel-380__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Boltane Çilek Reçeli 380 g',
      url: 'https://www.sokmarket.com.tr/boltane-cilek-receli-380-g-p-6930',
      price: 69.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Şitoğlu Ayva Reçel 380 gr',
      url: 'https://happycenter.com.tr/Sitoglu_Recel_380_Gr_Ayva',
      price: 99.8,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Tamek Gül Reçeli 380 G',
      url: 'https://www.macrocenter.com.tr/tamek-gul-receli-380-g-p-6b93dd',
      price: 109.95,
    ),
  },
  'sabun-4__duru': {
    MarketId.migros: MarketOffer(
      product: 'Duru Türk Hamamı Klasik Kalıp Sabun 4x200 G',
      url: 'https://www.migros.com.tr/duru-turk-hamami-klasik-kalip-sabun-4x200-g-p-1baa862',
      price: 179.95,
    ),
  },
  'salam-60__aytac': {
    MarketId.sok: MarketOffer(
      product: 'Aytaç Şipşak Dana Salam Dilimli 60 g',
      url: 'https://www.sokmarket.com.tr/aytac-sipsak-dana-salam-dilimli-60-g-p-7045',
      price: 42.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Aytaç Şipşak Dana Dilimli Macar Salam 60 G',
      url: 'https://www.migros.com.tr/aytac-sipsak-dana-dilimli-macar-salam-60-g-p-d7263c',
      price: 83.5,
    ),
  },
  'salam-60__banvit': {
    MarketId.hakmar: MarketOffer(
      product: 'Banvit Dilimli Piliç Salam 60G',
      url: 'https://www.hakmarexpress.com.tr/banvit-dilimli-pilic-salam-60g-1008061-p',
      price: 22.0,
    ),
  },
  'salam-60__maret': {
    MarketId.happyCenter: MarketOffer(
      product: 'Maret Hindi Salam Pratik 60gr',
      url: 'https://happycenter.com.tr/Maret_Pratik_Hindi_Salam_60_Gr',
      price: 41.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Maret Pratik Hindi Salam 60 G',
      url: 'https://www.migros.com.tr/maret-pratik-hindi-salam-60-g-p-d74a26',
      price: 55.75,
    ),
  },
  'salam-60__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Namet Dana Macar Salam 60 g',
      url: 'https://www.sokmarket.com.tr/namet-dana-macar-salam-60-g-p-6063',
      price: 56.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Danet Hindi Salam Tadımlık 60 gr',
      url: 'https://happycenter.com.tr/Danet_Hindi_Salam_Tadimlik_60_Gr',
      price: 33.2,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Banvit Dilimli Piliç Salam 60G',
      url: 'https://www.hakmarexpress.com.tr/banvit-dilimli-pilic-salam-60g-1008061-p',
      price: 22.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Namet 7 / 24 Hindi Salam 60 G',
      url: 'https://www.macrocenter.com.tr/namet-7-24-hindi-salam-60-g-p-d749eb',
      price: 26.75,
    ),
  },
  'salam-60__namet': {
    MarketId.sok: MarketOffer(
      product: 'Namet Dana Macar Salam 60 g',
      url: 'https://www.sokmarket.com.tr/namet-dana-macar-salam-60-g-p-6063',
      price: 56.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Namet 7/24 Hindi Salam 60 Gr',
      url: 'https://happycenter.com.tr/d-namet-hindi-salam-60-gr',
      price: 38.75,
    ),
    MarketId.migros: MarketOffer(
      product: 'Namet 7 / 24 Hindi Salam 60 G',
      url: 'https://www.migros.com.tr/namet-7-24-hindi-salam-60-g-p-d749eb',
      price: 26.75,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Namet 7/24 Dana Macar Salam 60 G',
      url: 'https://www.macrocenter.com.tr/namet-724-dana-macar-salam-60-g-p-d749e4',
      price: 56.5,
    ),
  },
  'salam-60__pinar': {
    MarketId.happyCenter: MarketOffer(
      product: 'Pınar Füme Aç Bitir Hindi Salam 60 Gr',
      url: 'https://happycenter.com.tr/pinar-ac-bitir-hindi-fume-buyuk-dilim-60-gr',
      price: 49.85,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Pınar Salam Hindi Aç Bitir Büyük Dilim 60 Gr',
      url: 'https://www.hakmarexpress.com.tr/pinar-salam-hindi-ac-bitir-buyuk-dilim-60-gr-1015595-p',
      price: 44.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Pınar Aç Bitir Hindi Salam Büyük Dilim 60 G',
      url: 'https://www.migros.com.tr/pinar-ac-bitir-hindi-salam-buyuk-dilim-60-g-p-d74a3f',
      price: 46.9,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Pınar Aç Bitir Hindi Salam Büyük Dilim 60 G',
      url: 'https://www.macrocenter.com.tr/pinar-ac-bitir-hindi-salam-buyuk-dilim-60-g-p-d74a3f',
      price: 46.9,
    ),
  },
  'salca-650__bizim-vatan': {
    MarketId.sok: MarketOffer(
      product: 'Tatlı Biber Salçası Bizim Vatan 650 g',
      url: 'https://www.sokmarket.com.tr/tatli-biber-salcasi-bizim-vatan-650-g-p-8365',
      price: 72.5,
    ),
  },
  'salca-650__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Tatlı Biber Salçası Bizim Vatan 650 g',
      url: 'https://www.sokmarket.com.tr/tatli-biber-salcasi-bizim-vatan-650-g-p-8365',
      price: 72.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'İpek Biber Salçası Tatlı 650 Gr Cam',
      url: 'https://happycenter.com.tr/Ipek_11_Biber_Salcasi_Tatli',
      price: 110.9,
    ),
  },
  'sampuan-400__duru': {
    MarketId.sok: MarketOffer(
      product: 'Duru Şampuan Güçlü Parlak 400 Ml',
      url: 'https://www.sokmarket.com.tr/duru-sampuan-guclu-parlak-400-ml-p-690888',
      price: 99.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Duru Şampuan Nem Bombası Yoğun Onarım 400ml',
      url: 'https://happycenter.com.tr/duru-sampuan-nem-bombasi-yogun-onarim-400ml',
      price: 88.65,
    ),
    MarketId.migros: MarketOffer(
      product: 'Duru Güçlü Parlak Şampuan 400 Ml',
      url: 'https://www.migros.com.tr/duru-guclu-parlak-sampuan-400-ml-p-20a822c',
      price: 99.95,
    ),
  },
  'sampuan-400__elidor': {
    MarketId.sok: MarketOffer(
      product: 'Elidor Anında Onarıcı Bakım Şampuan 400 ml',
      url: 'https://www.sokmarket.com.tr/elidor-aninda-onarici-bakim-sampuan-400-ml-p-2046',
      price: 149.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Elidor Anında Onarıcı Bakım Şampuan 400 Ml',
      url: 'https://happycenter.com.tr/elidor-aninda-onarici-bakim-sampuan-400-ml',
      price: 110.9,
    ),
    MarketId.migros: MarketOffer(
      product: 'Elidor Ultra Işıltı 100 Şampuan 400 Ml',
      url: 'https://www.migros.com.tr/elidor-ultra-isilti-100-sampuan-400-ml-p-20b3966',
      price: 154.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Elidor Ultra Işıltı 100 Şampuan 400 Ml',
      url: 'https://www.macrocenter.com.tr/elidor-ultra-isilti-100-sampuan-400-ml-p-20b3966',
      price: 250.0,
    ),
  },
  'sampuan-400__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Duru Şampuan Güçlü Parlak 400 Ml',
      url: 'https://www.sokmarket.com.tr/duru-sampuan-guclu-parlak-400-ml-p-690888',
      price: 99.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Sebamed Kepek Önleyici Şampuan 400 ml',
      url: 'https://happycenter.com.tr/Sebamed_200_Ml_Samp_Anti-hairloss',
      price: 665.85,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Gliss Supreme Length Şampuan 400 Ml',
      url: 'https://www.macrocenter.com.tr/gliss-supreme-length-sampuan-400-ml-p-20a9d81',
      price: 225.0,
    ),
  },
  'sarimsak-250__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Sarımsak 250 Gr',
      url: 'https://www.sokmarket.com.tr/sarimsak-250-gr-p-34665',
      price: 59.9,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Sarımsak 250 G',
      url: 'https://www.hakmarexpress.com.tr/sarimsak-250-g-1035007-p',
      price: 32.49,
    ),
  },
  'seker-1kg__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Türkşeker Toz Şeker 1000 GR',
      url: 'https://happycenter.com.tr/turkseker-toz-seker-1000-gr',
      price: 55.4,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Balküpü Toz Şeker 1000 Gr',
      url: 'https://www.hakmarexpress.com.tr/balkupu-toz-seker-1000-gr-1011191-p',
      price: 62.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Migros Toz Şeker 1 Kg',
      url: 'https://www.migros.com.tr/migros-toz-seker-1-kg-p-3281b4',
      price: 52.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Nar Toz Şeker 1Kg',
      url: 'https://www.macrocenter.com.tr/nar-toz-seker-1kg-p-2be4242',
      price: 59.95,
    ),
  },
  'seker-2kg__altinkup': {
    MarketId.sok: MarketOffer(
      product: 'Altınküp Toz Şeker 2000 g',
      url: 'https://www.sokmarket.com.tr/altinkup-toz-seker-2000-g-p-5298',
      price: 94.5,
    ),
  },
  'seker-2kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Altınküp Toz Şeker 2000 g',
      url: 'https://www.sokmarket.com.tr/altinkup-toz-seker-2000-g-p-5298',
      price: 94.5,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Akşeker Beyaz Kristal Toz Şeker 2 Kg',
      url: 'https://www.hakmarexpress.com.tr/akseker-beyaz-kristal-toz-seker-2-kg-1000286-p',
      price: 95.0,
    ),
  },
  'sogan-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Kuru Soğan Kg',
      url: 'https://www.sokmarket.com.tr/kuru-sogan-kg-p-32883',
      price: 54.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Soğan kuru kg',
      url: 'https://happycenter.com.tr/sogan-kuru',
      price: 78.15,
    ),
  },
  'sosis-190__aytac': {
    MarketId.sok: MarketOffer(
      product: 'Aytaç Dana Sosis 190 g',
      url: 'https://www.sokmarket.com.tr/aytac-dana-sosis-190-g-p-256466',
      price: 135.0,
    ),
  },
  'sosis-190__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Aytaç Dana Sosis 190 g',
      url: 'https://www.sokmarket.com.tr/aytac-dana-sosis-190-g-p-256466',
      price: 135.0,
    ),
  },
  'su-1-5l__erikli': {
    MarketId.happyCenter: MarketOffer(
      product: 'Erikli Su 1,5 lt',
      url: 'https://happycenter.com.tr/Erikli_1_5_Lt_Su_Pet',
      price: 33.2,
    ),
    MarketId.migros: MarketOffer(
      product: 'Erikli Su 1,5 L',
      url: 'https://www.migros.com.tr/erikli-su-15-l-p-7afc69',
      price: 38.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Erikli Su 1,5 L',
      url: 'https://www.macrocenter.com.tr/erikli-su-15-l-p-7afc69',
      price: 38.95,
    ),
  },
  'su-1-5l__hayat': {
    MarketId.happyCenter: MarketOffer(
      product: 'Hayat Su Pet Şişe 1,5 lt',
      url: 'https://happycenter.com.tr/Hayat_1_5_Lt_Su_Pet_Sise',
      price: 24.9,
    ),
  },
  'su-1-5l__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Saka Su 1.5 L',
      url: 'https://www.sokmarket.com.tr/saka-su-1-5-l-p-5905',
      price: 34.9,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Gümüş Su 1.5 Lt',
      url: 'https://happycenter.com.tr/gumus-su-1-5-lt',
      price: 6.1,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Assu Pet Şişe Su 1.5 lt',
      url: 'https://www.hakmarexpress.com.tr/assu-pet-sise-su-1-5-lt-1024167-p',
      price: 12.25,
    ),
    MarketId.migros: MarketOffer(
      product: 'Erikli Su 1,5 L',
      url: 'https://www.migros.com.tr/erikli-su-15-l-p-7afc69',
      price: 38.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Pınar Yaşam Pınarım Su Pet Şişe 1,5 L',
      url: 'https://www.macrocenter.com.tr/pinar-yasam-pinarim-su-pet-sise-15-l-p-7afe23',
      price: 36.95,
    ),
  },
  'su-1-5l__nestle-pure-life': {
    MarketId.migros: MarketOffer(
      product: 'Nestle Pure Life Su 1,5 L',
      url: 'https://www.migros.com.tr/nestle-pure-life-su-15-l-p-7b02d7',
      price: 31.75,
    ),
  },
  'su-1-5l__saka': {
    MarketId.sok: MarketOffer(
      product: 'Saka Su 1.5 L',
      url: 'https://www.sokmarket.com.tr/saka-su-1-5-l-p-5905',
      price: 34.9,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Saka Su 1,5 lt Pet',
      url: 'https://happycenter.com.tr/U_saka_Su_1_5_Lt',
      price: 32.1,
    ),
  },
  'su-5l__erikli': {
    MarketId.happyCenter: MarketOffer(
      product: 'Erikli Su 5 lt',
      url: 'https://happycenter.com.tr/Erikli_5_Lt_Su_Pet',
      price: 77.6,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Erikli Su Pet Şişe 5 Lt',
      url: 'https://www.hakmarexpress.com.tr/erikli-su-pet-sise-5-lt-1016461-p',
      price: 49.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Erikli Su 5 L',
      url: 'https://www.migros.com.tr/erikli-su-5-l-p-7b04fb',
      price: 54.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Erikli Su 5 L',
      url: 'https://www.macrocenter.com.tr/erikli-su-5-l-p-7b04fb',
      price: 77.95,
    ),
  },
  'su-5l__hayat': {
    MarketId.happyCenter: MarketOffer(
      product: 'Hayat Su Pet Şişe 5 lt',
      url: 'https://happycenter.com.tr/Hayat_5_Lt_Su_Pet_Sise',
      price: 67.7,
    ),
  },
  'su-5l__kardelen': {
    MarketId.sok: MarketOffer(
      product: 'Kardelen Su 5 lt',
      url: 'https://www.sokmarket.com.tr/kardelen-su-5-lt-p-5523',
      price: 36.0,
    ),
  },
  'su-5l__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Kardelen Su 5 lt',
      url: 'https://www.sokmarket.com.tr/kardelen-su-5-lt-p-5523',
      price: 36.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Aquasera Pet Su 5 Lt',
      url: 'https://happycenter.com.tr/aquasera-pet-su-5-lt',
      price: 24.95,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Assu Su Pet Şişe 5 Lt',
      url: 'https://www.hakmarexpress.com.tr/assu-su-pet-sise-5-lt-1024168-p',
      price: 36.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Erikli Su 5 L',
      url: 'https://www.migros.com.tr/erikli-su-5-l-p-7b04fb',
      price: 54.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Saka Doğal Mineralli Su 5 L',
      url: 'https://www.macrocenter.com.tr/saka-dogal-mineralli-su-5-l-p-7b081d',
      price: 57.5,
    ),
  },
  'su-5l__nestle-pure-life': {
    MarketId.migros: MarketOffer(
      product: 'Nestle Pure Life Su 5 L',
      url: 'https://www.migros.com.tr/nestle-pure-life-su-5-l-p-7b02d9',
      price: 59.0,
    ),
  },
  'su-5l__saka': {
    MarketId.sok: MarketOffer(
      product: 'Saka Su 5 L',
      url: 'https://www.sokmarket.com.tr/saka-su-5-l-p-8475',
      price: 57.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Saka Su 5 lt Pet',
      url: 'https://happycenter.com.tr/U_saka_Su_5_Lt',
      price: 63.75,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Saka Doğal Mineralli Su 5 L',
      url: 'https://www.macrocenter.com.tr/saka-dogal-mineralli-su-5-l-p-7b081d',
      price: 57.5,
    ),
  },
  'sucuk-250__aytac': {
    MarketId.sok: MarketOffer(
      product: 'Aytaç Çiftlik Kangal Sucuk Isıl İşlem 250 g',
      url: 'https://www.sokmarket.com.tr/aytac-ciftlik-kangal-sucuk-isil-islem-250-g-p-45889',
      price: 189.0,
    ),
  },
  'sucuk-250__erpilic': {
    MarketId.sok: MarketOffer(
      product: 'Erpiliç Piliç Kangal Sucuk 250 G',
      url: 'https://www.sokmarket.com.tr/erpilic-pilic-kangal-sucuk-250-g-p-73258',
      price: 67.5,
    ),
  },
  'sucuk-250__keskinoglu': {
    MarketId.sok: MarketOffer(
      product: 'Keskinoğlu Kangal Sucuk 250 g',
      url: 'https://www.sokmarket.com.tr/keskinoglu-kangal-sucuk-250-g-p-79687',
      price: 67.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'Keskinoğlu Piliç Sucuk 250 G',
      url: 'https://www.migros.com.tr/keskinoglu-pilic-sucuk-250-g-p-d8d131',
      price: 72.9,
    ),
  },
  'sucuk-250__maret': {
    MarketId.happyCenter: MarketOffer(
      product: 'Maret Dana Sucuk Kangal Fermente 250 Gr.',
      url: 'https://happycenter.com.tr/maret-dana-sucuk-kangal-fermente-400-gr-',
      price: 310.7,
    ),
    MarketId.migros: MarketOffer(
      product: 'Maret Altın Seri Sucuk 250 G',
      url: 'https://www.migros.com.tr/maret-altin-seri-sucuk-250-g-p-d8acc3',
      price: 565.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Maret Altın Seri Sucuk 250 G',
      url: 'https://www.macrocenter.com.tr/maret-altin-seri-sucuk-250-g-p-d8acc3',
      price: 575.0,
    ),
  },
  'sucuk-250__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Keskinoğlu Kangal Sucuk 250 g',
      url: 'https://www.sokmarket.com.tr/keskinoglu-kangal-sucuk-250-g-p-79687',
      price: 67.5,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'DoyFarm  Piliç Sucuk 250 gr',
      url: 'https://www.hakmarexpress.com.tr/doyfarm-pilic-sucuk-250-gr-1018144-p',
      price: 67.5,
    ),
  },
  'sucuk-250__namet': {
    MarketId.hakmar: MarketOffer(
      product: 'Namet Sucuk Dana Kangal 250 G',
      url: 'https://www.hakmarexpress.com.tr/namet-sucuk-dana-kangal-250-g-1028935-p',
      price: 189.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Namet Dana Kasap Sucuk 250 G',
      url: 'https://www.migros.com.tr/namet-dana-kasap-sucuk-250-g-p-d8d1b8',
      price: 299.0,
    ),
  },
  'sucuk-250__pinar': {
    MarketId.happyCenter: MarketOffer(
      product: 'Pınar Dana Sucuk Fermente Gurme 250 Gr',
      url: 'https://happycenter.com.tr/Pinar_Dana_Sucuk_Gurme_250_Gr_',
      price: 588.2,
    ),
    MarketId.migros: MarketOffer(
      product: 'Pınar Gurme Sucuk 250 G',
      url: 'https://www.migros.com.tr/pinar-gurme-sucuk-250-g-p-d8d0c9',
      price: 609.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Pınar Gurme Sucuk 250 G',
      url: 'https://www.macrocenter.com.tr/pinar-gurme-sucuk-250-g-p-d8d0c9',
      price: 621.95,
    ),
  },
  'sucuk-250__sultan': {
    MarketId.sok: MarketOffer(
      product: 'Sultan Kangal Sucuk Isıl İşlem 250 g',
      url: 'https://www.sokmarket.com.tr/sultan-kangal-sucuk-isil-islem-250-g-p-5651',
      price: 189.0,
    ),
  },
  'sut-1l__icim': {
    MarketId.happyCenter: MarketOffer(
      product: 'İçim Süt Tam Yağlı Uht 1 lt',
      url: 'https://happycenter.com.tr/Icim_Sut_11_Tam_Yagli',
      price: 75.95,
    ),
  },
  'sut-1l__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mis Bakraçlık Süt Tam Yağlı 1 L',
      url: 'https://www.sokmarket.com.tr/mis-bakraclik-sut-tam-yagli-1-l-p-7501',
      price: 59.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Pınar Süt Tam Yağlı Uht 1 lt',
      url: 'https://happycenter.com.tr/Pinar_Sut_11_Tam_Yagli',
      price: 88.0,
    ),
  },
  'sut-1l__mis': {
    MarketId.sok: MarketOffer(
      product: 'Mis Bakraçlık Süt Tam Yağlı 1 L',
      url: 'https://www.sokmarket.com.tr/mis-bakraclik-sut-tam-yagli-1-l-p-7501',
      price: 59.5,
    ),
  },
  'sut-1l__pinar': {
    MarketId.happyCenter: MarketOffer(
      product: 'Pınar Süt Tam Yağlı Uht 1 lt',
      url: 'https://happycenter.com.tr/Pinar_Sut_11_Tam_Yagli',
      price: 88.0,
    ),
  },
  'sut-1l__sek': {
    MarketId.migros: MarketOffer(
      product: 'Sek Çiftlik Tam Yağlı Pastörize Günlük Süt 1 L',
      url: 'https://www.migros.com.tr/sek-ciftlik-tam-yagli-pastorize-gunluk-sut-1-l-p-a82689',
      price: 115.0,
    ),
  },
  'sut-yarim-1l__icim': {
    MarketId.happyCenter: MarketOffer(
      product: 'İçim Süt Yarım Yağlı Uht 1/1',
      url: 'https://happycenter.com.tr/b--icim-sut-11-y-yagli',
      price: 65.4,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'İçim Süt Yarım Yağlı 1 Lt',
      url: 'https://www.hakmarexpress.com.tr/icim-sut-yarim-yagli-1-lt-1009421-p',
      price: 57.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'İçim Yarım Yağlı Süt 1 L',
      url: 'https://www.migros.com.tr/icim-yarim-yagli-sut-1-l-p-a811a7',
      price: 59.75,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'İçim Yarım Yağlı Süt 1 L',
      url: 'https://www.macrocenter.com.tr/icim-yarim-yagli-sut-1-l-p-a811a7',
      price: 59.75,
    ),
  },
  'sut-yarim-1l__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mis Gold Kaymaklı Yarım Yağlı 1000 ml',
      url: 'https://www.sokmarket.com.tr/mis-gold-kaymakli-yarim-yagli-1000-ml-p-5896',
      price: 165.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Yörsan Süt Yarım Yağlı Uht 1/1',
      url: 'https://happycenter.com.tr/yorsan-sut-yarim-yagli-uht-11',
      price: 46.55,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'İçim Süt Yarım Yağlı 1 Lt',
      url: 'https://www.hakmarexpress.com.tr/icim-sut-yarim-yagli-1-lt-1009421-p',
      price: 57.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'İçim Yarım Yağlı Süt 1 L',
      url: 'https://www.migros.com.tr/icim-yarim-yagli-sut-1-l-p-a811a7',
      price: 59.75,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'İçim Yarım Yağlı Süt 1 L',
      url: 'https://www.macrocenter.com.tr/icim-yarim-yagli-sut-1-l-p-a811a7',
      price: 59.75,
    ),
  },
  'sut-yarim-1l__mis': {
    MarketId.sok: MarketOffer(
      product: 'Mis Gold Kaymaklı Yarım Yağlı 1000 ml',
      url: 'https://www.sokmarket.com.tr/mis-gold-kaymakli-yarim-yagli-1000-ml-p-5896',
      price: 165.0,
    ),
  },
  'sut-yarim-1l__sutas': {
    MarketId.happyCenter: MarketOffer(
      product: 'Sütaş Süt Yarım Yağlı Uht 1/1',
      url: 'https://happycenter.com.tr/D_sutas_11_Uht_Sut_Yarim_Yagli',
      price: 63.2,
    ),
  },
  'tavuk-1kg__banvit': {
    MarketId.migros: MarketOffer(
      product: 'Banvit Piliç Pirzola Kg',
      url: 'https://www.migros.com.tr/banvit-pilic-pirzola-kg-p-2be8451',
      price: 239.95,
    ),
  },
  'tavuk-1kg__gedik': {
    MarketId.sok: MarketOffer(
      product: 'Gedik Piliç But Pirzola Kg',
      url: 'https://www.sokmarket.com.tr/gedik-pilic-but-pirzola-kg-p-461813',
      price: 249.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Gedik Soslu Piliç Pirzola Kg',
      url: 'https://www.migros.com.tr/gedik-soslu-pilic-pirzola-kg-p-c6a975',
      price: 339.95,
    ),
  },
  'tavuk-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Gedik Piliç But Pirzola Kg',
      url: 'https://www.sokmarket.com.tr/gedik-pilic-but-pirzola-kg-p-461813',
      price: 249.0,
    ),
  },
  'tereyag-500__icim': {
    MarketId.happyCenter: MarketOffer(
      product: 'İçim Tereyağı 500 gr',
      url: 'https://happycenter.com.tr/Icim_Tereyag_500_Gr_Rulo',
      price: 510.5,
    ),
    MarketId.migros: MarketOffer(
      product: 'İçim Tereyağı 500 G',
      url: 'https://www.migros.com.tr/icim-tereyagi-500-g-p-b74315',
      price: 478.95,
    ),
  },
  'tereyag-500__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mis Tereyağı 500 g',
      url: 'https://www.sokmarket.com.tr/mis-tereyagi-500-g-p-7204',
      price: 279.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'İçim Tereyağı 500 gr',
      url: 'https://happycenter.com.tr/Icim_Tereyag_500_Gr_Rulo',
      price: 510.5,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Haktat Tereyağı 500 Gr',
      url: 'https://www.hakmarexpress.com.tr/haktat-tereyagi-500-gr-1031669-p',
      price: 369.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Migros Tereyağ 500 G',
      url: 'https://www.migros.com.tr/migros-tereyag-500-g-p-b75d8e',
      price: 309.9,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Hasmandıra Tereyağ Topak 500 G',
      url: 'https://www.macrocenter.com.tr/hasmandira-tereyag-topak-500-g-p-b74251',
      price: 533.9,
    ),
  },
  'tereyag-500__mis': {
    MarketId.sok: MarketOffer(
      product: 'Mis Tereyağı 500 g',
      url: 'https://www.sokmarket.com.tr/mis-tereyagi-500-g-p-7204',
      price: 279.0,
    ),
  },
  'tuvalet-16__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Confort Geri Dönüşüm Tuvalet Kağıdı 16\'lı',
      url: 'https://www.sokmarket.com.tr/confort-geri-donusum-tuvalet-kagidi-16-li-p-498728',
      price: 105.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Famılıa Tuvalet Kagıdı Kıs Serısı 16 Lı',
      url: 'https://happycenter.com.tr/familia-parfumlu-kis-serisi-16-li-tuv-kagidi',
      price: 110.9,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Selis Çift Katlı Tuvalet Kağıdı 16\'lı',
      url: 'https://www.hakmarexpress.com.tr/selis-cift-katli-tuvalet-kagidi-16li-1014368-p',
      price: 123.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Selpak Tuvalet Kağıdı 16\'lı',
      url: 'https://www.migros.com.tr/selpak-tuvalet-kagidi-16li-p-1d934a8',
      price: 339.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Selpak Tuvalet Kağıdı 16\'lı',
      url: 'https://www.macrocenter.com.tr/selpak-tuvalet-kagidi-16li-p-1d934a8',
      price: 339.95,
    ),
  },
  'tuvalet-16__selpak': {
    MarketId.happyCenter: MarketOffer(
      product: 'Selpak Extra Pamuksu Doku Tuvalet Kağıdı 16 Lı',
      url: 'https://happycenter.com.tr/selpak-deluxe-re-fresh-parf--tk-24-lu',
      price: 221.9,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Selpak Ekstra 3 Katlı Tuvalet Kağıdı 16\'lı',
      url: 'https://www.hakmarexpress.com.tr/selpak-ekstra-3-katli-tuvalet-kagidi-16li-1024919-p',
      price: 199.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Selpak Tuvalet Kağıdı 16\'lı',
      url: 'https://www.migros.com.tr/selpak-tuvalet-kagidi-16li-p-1d934a8',
      price: 339.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Selpak Tuvalet Kağıdı 16\'lı',
      url: 'https://www.macrocenter.com.tr/selpak-tuvalet-kagidi-16li-p-1d934a8',
      price: 339.95,
    ),
  },
  'tuz-500__billur': {
    MarketId.sok: MarketOffer(
      product: 'Billur Tuz Rafine İyotlu Sofra Tuzu 500 g',
      url: 'https://www.sokmarket.com.tr/billur-tuz-rafine-iyotlu-sofra-tuzu-500-g-p-8155',
      price: 54.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Billur Tuzluklu İyotlu Sofra Tuzu 500 gr',
      url: 'https://happycenter.com.tr/Billur_500_Gr_Tuz_Tuzluklu_Mavi_Kutu',
      price: 64.3,
    ),
    MarketId.migros: MarketOffer(
      product: 'Billur Tuz İyotlu Sofra Tuzu Pet 500 G',
      url: 'https://www.migros.com.tr/billur-tuz-iyotlu-sofra-tuzu-pet-500-g-p-5bdfef',
      price: 41.96,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Billur Tuz İyotlu Sofra Tuzu 500 G ( Tuzluklu )',
      url: 'https://www.macrocenter.com.tr/billur-tuz-iyotlu-sofra-tuzu-500-g-tuzluklu-p-5bdff0',
      price: 59.95,
    ),
  },
  'tuz-500__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Billur Tuz Rafine İyotlu Sofra Tuzu 500 g',
      url: 'https://www.sokmarket.com.tr/billur-tuz-rafine-iyotlu-sofra-tuzu-500-g-p-8155',
      price: 54.5,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Billur Tuzluklu İyotlu Sofra Tuzu 500 gr',
      url: 'https://happycenter.com.tr/Billur_500_Gr_Tuz_Tuzluklu_Mavi_Kutu',
      price: 64.3,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Billur Tuz İyotlu Sofra Tuzu 500 G ( Tuzluklu )',
      url: 'https://www.macrocenter.com.tr/billur-tuz-iyotlu-sofra-tuzu-500-g-tuzluklu-p-5bdff0',
      price: 59.95,
    ),
  },
  'un-5kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Piyale Un 5 Kg',
      url: 'https://www.sokmarket.com.tr/piyale-un-5-kg-p-8539',
      price: 135.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Happy Sweet Un 5 kg',
      url: 'https://happycenter.com.tr/happy-sweet-un-5-kg',
      price: 77.6,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Akun Un 5 Kg',
      url: 'https://www.hakmarexpress.com.tr/akun-un-5-kg-1000285-p',
      price: 135.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Söke Un 5 Kg',
      url: 'https://www.migros.com.tr/soke-un-5-kg-p-4c73e5',
      price: 219.95,
    ),
  },
  'un-5kg__piyale': {
    MarketId.sok: MarketOffer(
      product: 'Piyale Un 5 Kg',
      url: 'https://www.sokmarket.com.tr/piyale-un-5-kg-p-8539',
      price: 135.0,
    ),
  },
  'yogurt-1kg__eker': {
    MarketId.happyCenter: MarketOffer(
      product: 'Eker Yoğurt Kaymaklı Tava 1000 Gr',
      url: 'https://happycenter.com.tr/Eker_Comlek_Yogurt_1000_Gr',
      price: 148.3,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Eker Kaymaklı Tava Yoğurt 1000 Gr',
      url: 'https://www.hakmarexpress.com.tr/eker-kaymakli-tava-yogurt-1000-gr-1014164-p',
      price: 119.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Eker Kaymaklı Tava Yoğurt 1 Kg',
      url: 'https://www.macrocenter.com.tr/eker-kaymakli-tava-yogurt-1-kg-p-bec383',
      price: 142.5,
    ),
  },
  'yogurt-1kg__icim': {
    MarketId.sok: MarketOffer(
      product: 'İçim Tam Yağlı Kaymaksız Yoğurt 1 Kg',
      url: 'https://www.sokmarket.com.tr/icim-tam-yagli-kaymaksiz-yogurt-1-kg-p-4624',
      price: 89.9,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'İçim Yoğurt Kaymaksız 1000 Gr',
      url: 'https://happycenter.com.tr/Icim_Yogurt_1000_Gr_Kaymaksiz',
      price: 116.45,
    ),
  },
  'yogurt-1kg__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Mis Kaymaklı Yoğurt 1 kg',
      url: 'https://www.sokmarket.com.tr/mis-kaymakli-yogurt-1-kg-p-2229',
      price: 84.9,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'YORSAN YOGURT KAYMAKLI TAVA 1000 GR',
      url: 'https://happycenter.com.tr/Yorsan_Yogurt_2000_Gr_Kaymakli_Tava',
      price: 86.5,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Safgül Manda Sütlü  Yoğurt 1000 gr',
      url: 'https://www.hakmarexpress.com.tr/safgul-manda-sutlu-yogurt-1000-gr-1026410-p',
      price: 109.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Eker Kaymaklı Tava Yoğurt 1 Kg',
      url: 'https://www.macrocenter.com.tr/eker-kaymakli-tava-yogurt-1-kg-p-bec383',
      price: 142.5,
    ),
  },
  'yogurt-1kg__mis': {
    MarketId.sok: MarketOffer(
      product: 'Mis Kaymaklı Yoğurt 1 kg',
      url: 'https://www.sokmarket.com.tr/mis-kaymakli-yogurt-1-kg-p-2229',
      price: 84.9,
    ),
  },
  'yogurt-1kg__sutas': {
    MarketId.happyCenter: MarketOffer(
      product: 'Sütaş Yoğurt Kaymaksız 1000 gr',
      url: 'https://happycenter.com.tr/Sutas_Yogurt_1000_Gr_Kaymaksiz',
      price: 99.3,
    ),
    MarketId.migros: MarketOffer(
      product: 'Sütaş Kaymaksız Yoğurt 1000 G',
      url: 'https://www.migros.com.tr/sutas-kaymaksiz-yogurt-1000-g-p-bebd9c',
      price: 89.95,
    ),
  },
  'yumurta-15__anadolu-ciftligi': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Çiftliği L Yumurta 15\'li (63-72 g)',
      url: 'https://www.sokmarket.com.tr/anadolu-ciftligi-l-yumurta-15-li-63-72-g-p-4821',
      price: 64.9,
    ),
  },
  'yumurta-15__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Çiftliği L Yumurta 15\'li (63-72 g)',
      url: 'https://www.sokmarket.com.tr/anadolu-ciftligi-l-yumurta-15-li-63-72-g-p-4821',
      price: 64.9,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Kay-Yum Yumurta L Boy 15 Li (63-72 Gr)',
      url: 'https://happycenter.com.tr/Kaya_Yumurta_15_Li_Pk_',
      price: 83.15,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Naturaköy Gezen Tavuk 15\'Li Yumurta',
      url: 'https://www.macrocenter.com.tr/naturakoy-gezen-tavuk-15li-yumurta-p-2bebb85',
      price: 169.95,
    ),
  },
  'yumurta-30__anadolu-ciftligi': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Çiftliği M Yumurta 30\'lu (53-63 g)',
      url: 'https://www.sokmarket.com.tr/anadolu-ciftligi-m-yumurta-30-lu-53-63-g-p-4948',
      price: 129.0,
    ),
  },
  'yumurta-30__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Anadolu Çiftliği M Yumurta 30\'lu (53-63 g)',
      url: 'https://www.sokmarket.com.tr/anadolu-ciftligi-m-yumurta-30-lu-53-63-g-p-4948',
      price: 129.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'KESKINOGLU YUMURTA SMALL 30 LU',
      url: 'https://happycenter.com.tr/Keskinoglu_Yumurta_30_Lu_Small',
      price: 110.9,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Yumtat Beyaz Yumurta 30\'lu 53-62 Gr',
      url: 'https://www.hakmarexpress.com.tr/yumtat-beyaz-yumurta-30lu-53-62-gr-1000009-p',
      price: 129.0,
    ),
  },
  'yumusatici-1440__bingo': {
    MarketId.migros: MarketOffer(
      product: 'Bingo Soft Begonvil Yumuşatıcı 1440 Ml',
      url: 'https://www.migros.com.tr/bingo-soft-begonvil-yumusatici-1440-ml-p-1d2c1d0',
      price: 149.95,
    ),
  },
  'yumusatici-1440__markasiz': {
    MarketId.happyCenter: MarketOffer(
      product: 'Vernel Max Gül Yumuşatıcı 1440 ml',
      url: 'https://happycenter.com.tr/Vernel_Max_1500_Ml_Gul',
      price: 133.1,
    ),
  },
  'yumusatici-1440__peros': {
    MarketId.sok: MarketOffer(
      product: 'Peros Konsantre Yumuşatıcı İnci Çiçeği 1440 Ml',
      url: 'https://www.sokmarket.com.tr/peros-konsantre-yumusatici-inci-cicegi-1440-ml-p-542785',
      price: 149.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Peros Konsantre Yumuşatıcı Lavanta Begonvil 1440 Ml',
      url: 'https://www.migros.com.tr/peros-konsantre-yumusatici-lavanta-begonvil-1440-ml-p-1d227fb',
      price: 149.95,
    ),
  },
  'zeytin-500__lio': {
    MarketId.sok: MarketOffer(
      product: 'Lio Salamura Siyah Zeytin (321-380) 500 g',
      url: 'https://www.sokmarket.com.tr/lio-salamura-siyah-zeytin-321-380-500-g-p-8221',
      price: 115.0,
    ),
  },
  'zeytin-500__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Lio Salamura Siyah Zeytin (321-380) 500 g',
      url: 'https://www.sokmarket.com.tr/lio-salamura-siyah-zeytin-321-380-500-g-p-8221',
      price: 115.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Gürağaç Zeytin Yağlı Siyah 500 Gr (351-380 2XS)',
      url: 'https://happycenter.com.tr/guragac-zeytin-yagli-siyah-500-gr-351-380-2xs',
      price: 83.15,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Marmarabirlik Extra Zeytin 500 G 321-350 Ad/Kg',
      url: 'https://www.macrocenter.com.tr/marmarabirlik-extra-zeytin-500-g-321-350-adkg-p-f44cba',
      price: 169.0,
    ),
  },
  'zeytinyagi-1l__komili': {
    MarketId.happyCenter: MarketOffer(
      product: 'Komili Y.Zeytinyaği Yemeklik Riviera Pet 1 Lt',
      url: 'https://happycenter.com.tr/Komili_Y_zeytinyagi_Riviera_1_Lt',
      price: 399.5,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Komili Zeytinyağı Riviera Yemeklik 1 Lt',
      url: 'https://www.hakmarexpress.com.tr/komili-zeytinyagi-riviera-yemeklik-1-lt-1007580-p',
      price: 279.0,
    ),
    MarketId.migros: MarketOffer(
      product: 'Komili Lezzetlik Yumuşak Natürel Sızma Zeytinyağı 1 L',
      url: 'https://www.migros.com.tr/komili-lezzetlik-yumusak-naturel-sizma-zeytinyagi-1-l-p-3f1231',
      price: 382.46,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Komili Sızma Zeytinyağı 1 L',
      url: 'https://www.macrocenter.com.tr/komili-sizma-zeytinyagi-1-l-p-3f1219',
      price: 539.95,
    ),
  },
  'zeytinyagi-1l__lio': {
    MarketId.sok: MarketOffer(
      product: 'Lio Riviera Zeytinyağı 1 L',
      url: 'https://www.sokmarket.com.tr/lio-riviera-zeytinyagi-1-l-p-8748',
      price: 269.0,
    ),
  },
  'zeytinyagi-1l__markasiz': {
    MarketId.sok: MarketOffer(
      product: 'Lio Riviera Zeytinyağı 1 L',
      url: 'https://www.sokmarket.com.tr/lio-riviera-zeytinyagi-1-l-p-8748',
      price: 269.0,
    ),
    MarketId.happyCenter: MarketOffer(
      product: 'Yudum Egemden Riviera Zeytinyağı Pet 1 lt',
      url: 'https://happycenter.com.tr/Yudum_Y_zeytinyagi_Riviera_1_Lt',
      price: 355.1,
    ),
    MarketId.hakmar: MarketOffer(
      product: 'Komili Zeytinyağı Riviera Yemeklik 1 Lt',
      url: 'https://www.hakmarexpress.com.tr/komili-zeytinyagi-riviera-yemeklik-1-lt-1007580-p',
      price: 279.0,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Yudum Egemden Riviera Zeytinyağı 1 L',
      url: 'https://www.macrocenter.com.tr/yudum-egemden-riviera-zeytinyagi-1-l-p-3f090d',
      price: 431.95,
    ),
  },
  'zeytinyagi-1l__yudum': {
    MarketId.happyCenter: MarketOffer(
      product: 'Yudum Egemden Riviera Zeytinyağı Pet 1 lt',
      url: 'https://happycenter.com.tr/Yudum_Y_zeytinyagi_Riviera_1_Lt',
      price: 355.1,
    ),
    MarketId.migros: MarketOffer(
      product: 'Yudum Egemden Rıvıera Zeytinyağı 1L',
      url: 'https://www.migros.com.tr/yudum-egemden-riviera-zeytinyagi-1l-p-3f090d',
      price: 422.95,
    ),
    MarketId.macrocenter: MarketOffer(
      product: 'Yudum Egemden Riviera Zeytinyağı 1 L',
      url: 'https://www.macrocenter.com.tr/yudum-egemden-riviera-zeytinyagi-1-l-p-3f090d',
      price: 431.95,
    ),
  },
};
