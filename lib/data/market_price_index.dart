/// marketfiyati.org.tr (TÜBİTAK) fiyat indeksinden alınan market fiyatları.
///
/// Servis yedi zincirin kasa fiyatlarını yayınlar: BİM, A101, Şok, Migros,
/// CarrefourSA, Hakmar Express ve Tarım Kredi (KOOP) Market. Buradaki her
/// kayıt `ürün tipi__marka` kimliğine bağlıdır ve o markette listelenen
/// ürünün adı ile gramajı birlikte tutulur; böylece sepetteki marka ve birim
/// karşılaştırma boyunca değişmez.
///
/// Çekim: 2026-07-26 · İstanbul depoları · 126 ürün,
/// 292 market fiyatı. Fiyat, o markette birden fazla şube
/// listeliyorsa şube fiyatlarının medyanıdır.
library;

import '../models/market.dart';

class MarketIndexPrice {
  const MarketIndexPrice({
    required this.price,
    required this.product,
    this.unit,
  });

  /// Markette yayınlanan raf fiyatı.
  final double price;

  /// Markette listelenen ürün adı (marka + gramaj doğrulaması için).
  final String product;

  /// İndeksin bildirdiği gramaj/hacim (ör. `500 GR`).
  final String? unit;
}

const marketPriceIndexSource = 'marketfiyati.org.tr';
const marketPriceIndexFetchedAt = '2026-07-26';
const marketPriceIndexRegion = 'İstanbul';

/// `ürün tipi__marka` -> market -> doğrulanmış fiyat.
const marketPriceIndex = <String, Map<MarketId, MarketIndexPrice>>{
  'aycicek-1l__evin': {
    MarketId.sok: MarketIndexPrice(
      price: 122.0,
      product: 'Evin Ayçiçek Yağı 1 Lt',
      unit: '1 LT',
    ),
  },
  'aycicek-1l__komili': {
    MarketId.migros: MarketIndexPrice(
      price: 199.95,
      product: 'Komili Ayçiçek Yağı 1 Lt',
      unit: '1 LT',
    ),
  },
  'aycicek-1l__yudum': {
    MarketId.migros: MarketIndexPrice(
      price: 209.95,
      product: 'Yudum Ayçiçek Yağı 1 Lt',
      unit: '1 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 149.9,
      product: 'Yudum Ayçiçek Yağı 1 Lt',
      unit: '1 LT',
    ),
  },
  'aycicek-5l__evin': {
    MarketId.sok: MarketIndexPrice(
      price: 469.0,
      product: 'Evin Ayçiçek Yağı 5 Lt',
      unit: '5 LT',
    ),
  },
  'aycicek-5l__komili': {
    MarketId.a101: MarketIndexPrice(
      price: 544.5,
      product: 'Komili Ayçiçek Yağı 5 Lt',
      unit: '5 LT',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 544.95,
      product: 'Komili Ayçiçek Yağı 5 Lt',
      unit: '5 LT',
    ),
  },
  'aycicek-5l__yudum': {
    MarketId.migros: MarketIndexPrice(
      price: 549.95,
      product: 'Yudum Ayçiçek Yağı Köşeli Pet 5 Lt',
      unit: '5 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 469.0,
      product: 'Yudum Ayçiçek Yağı Köşeli Pet 5 Lt',
      unit: '5 LT',
    ),
  },
  'ayran-285__mis': {
    MarketId.sok: MarketIndexPrice(
      price: 13.5,
      product: 'Mis Bardak Ayran Tam Yağlı 285 Ml',
      unit: '285 ML',
    ),
  },
  'bebek-bezi__bebeland': {
    MarketId.sok: MarketIndexPrice(
      price: 90.0,
      product: 'Bebeland Bebek Bezi Mini 58 Adet',
      unit: null,
    ),
  },
  'bebek-bezi__sleepy': {
    MarketId.migros: MarketIndexPrice(
      price: 299.95,
      product: 'Sleepy Natural Jumbo Paket 5 No Junior Bebek Bezi 40 Adet',
      unit: null,
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 179.9,
      product: 'Sleepy Extra Jumbo Midi Bebek Bezi 56 Adet',
      unit: null,
    ),
  },
  'biskuvi-102__eti': {
    MarketId.bim: MarketIndexPrice(
      price: 69.0,
      product: 'Eti Kremalı Petibör Bisküvi 170 Gr',
      unit: '270 GR',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 25.0,
      product: 'Eti Kakaolu Bisküvi 125 Gr',
      unit: '125 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 25.0,
      product: 'Eti Kakaolu Bisküvi 125 Gr',
      unit: '125 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 24.95,
      product: 'Eti Kakaolu Bisküvi 125 Gr',
      unit: '125 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 25.75,
      product: 'Eti Kakaolu Bisküvi 125 Gr',
      unit: '125 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 25.0,
      product: 'Eti Cin Bisküvi 114 Gr',
      unit: '114 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 29.9,
      product: 'Eti Nero Kakaolu Bisküvi 110 Gr',
      unit: '110 GR',
    ),
  },
  'biskuvi-102__olen': {
    MarketId.hakmar: MarketIndexPrice(
      price: 49.0,
      product: 'Şölen Ozmo Hoppo Çikolata Dolgulu Bisküvi 90 Gr',
      unit: '90 GR',
    ),
  },
  'biskuvi-102__torku': {
    MarketId.bim: MarketIndexPrice(
      price: 35.0,
      product: 'Torku Kremalı Bisküvi Çeşitleri 183 Gr',
      unit: '183 GR',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 49.0,
      product: 'Torku Tam Çikolatam Kremalı Bisküvi 3x83 Gr',
      unit: '249 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 59.95,
      product: 'Torku Tam Çikolatam Kremalı Bisküvi 3x83 Gr',
      unit: '249 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 26.9,
      product: 'Torku Tam Çikolatam Bisküvi 83 Gr',
      unit: '83 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 29.75,
      product: 'Torku Tam Çikolatalı Bisküvi 83 Gr',
      unit: '83 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 94.9,
      product: 'Torku Pötibör Bisküvi 4x175 Gr',
      unit: '700 GR',
    ),
  },
  'biskuvi-102__lker': {
    MarketId.sok: MarketIndexPrice(
      price: 30.0,
      product: 'Ülker Pötibör Bisküvi 175 Gr',
      unit: '175 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 29.95,
      product: 'Ülker Pötibör Bisküvi 175 Gr',
      unit: '175 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 30.75,
      product: 'Ülker Pötibör Bisküvi 175 Gr',
      unit: '175 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 29.5,
      product: 'Ülker Petibör Bisküvi 175 Gr',
      unit: '175 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 64.0,
      product: 'Ülker İkram Fındıklı Bisküvi 3x84 Gr',
      unit: '252 GR',
    ),
  },
  'bulasik-1500__bingo': {
    MarketId.migros: MarketIndexPrice(
      price: 229.95,
      product: 'Bingo Limonlu Elde Bulaşık Deterjanı 1.5 Lt',
      unit: '1.5 LT',
    ),
  },
  'bulgur-1kg__anadolu-mutfagi': {
    MarketId.sok: MarketIndexPrice(
      price: 34.0,
      product: 'Anadolu Mutfağı Köftelik Bulgur 1 Kg',
      unit: '1 KG',
    ),
  },
  'bulgur-1kg__reis': {
    MarketId.carrefour: MarketIndexPrice(
      price: 79.95,
      product: 'Reis Köftelik Bulgur 1 Kg',
      unit: '1 KG',
    ),
  },
  'bulgur-1kg__yayla': {
    MarketId.migros: MarketIndexPrice(
      price: 49.95,
      product: 'Yayla Köftelik Bulgur 1 Kg',
      unit: '1 KG',
    ),
  },
  'cay-1000__aykur': {
    MarketId.bim: MarketIndexPrice(
      price: 356.0,
      product: 'Çaykur Tiryaki 1 Kg',
      unit: '1 KG',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 279.95,
      product: 'Çaykur Filiz Çayı 1 Kg',
      unit: '1 KG',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 356.0,
      product: 'Çaykur Tiryaki Çay 1 Kg',
      unit: '1 KG',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 439.95,
      product: 'Çaykur Filiz Çayı 1 Kg',
      unit: '1 KG',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 359.9,
      product: 'Çaykur Filiz 1 Kg',
      unit: '1 KG',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 356.0,
      product: 'Çaykur Tiryaki 1 Kg',
      unit: '1 KG',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 345.0,
      product: 'Çaykur Tiryaki Çay 1 Kg',
      unit: '1 KG',
    ),
  },
  'cay-1000__dogus': {
    MarketId.bim: MarketIndexPrice(
      price: 260.0,
      product: 'Doğuş Filiz Siyah Çay 1 Kg',
      unit: '1 KG',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 269.0,
      product: 'Doğuş Rize Çay 1 Kg',
      unit: '1 KG',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 325.0,
      product: 'Doğuş Filiz Çayı 1 Kg',
      unit: '1 KG',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 319.95,
      product: 'Doğuş Rize Çay 1 Kg',
      unit: '1 KG',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 223.99,
      product: 'Doğuş Rize Çayı 1 Kg',
      unit: '1 KG',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 325.0,
      product: 'Doğuş Filiz Siyah Çay 1 Kg',
      unit: '1 KG',
    ),
  },
  'cay-1000__lipton': {
    MarketId.bim: MarketIndexPrice(
      price: 369.0,
      product: 'Lipton Doğu Karadeniz Çayı 1 Kg',
      unit: '1 KG',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 379.0,
      product: 'Lipton Yellow Label Çay 1 Kg',
      unit: '1 KG',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 369.0,
      product: 'Lipton Doğu Karadeniz Çayı 1 Kg',
      unit: '1 KG',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 299.95,
      product: 'Lipton Tiryaki Çay 1 Kg',
      unit: '1 KG',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 244.99,
      product: 'Lipton Doğu Karadeniz Çayı 1 Kg',
      unit: '1 KG',
    ),
  },
  'cay-1000__ofcay': {
    MarketId.migros: MarketIndexPrice(
      price: 279.95,
      product: 'Ofçay Hazine Dökme Çay 1 Kg',
      unit: '1 KG',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 313.0,
      product: 'Ofçay Tiryaki Siyah Çay 1 Kg',
      unit: '1 KG',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 265.0,
      product: 'Ofçay Tiryaki Siyah Çay 1 Kg',
      unit: '1 KG',
    ),
  },
  'cay-500__aykur': {
    MarketId.a101: MarketIndexPrice(
      price: 225.0,
      product: 'Çaykur Filiz Çay 500 Gr',
      unit: '500 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 225.0,
      product: 'Çaykur Filiz Çay 500 Gr',
      unit: '500 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 224.95,
      product: 'Çaykur Filiz Çay 500 Gr',
      unit: '500 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 224.95,
      product: 'Çaykur Filiz 500 Gr',
      unit: '500 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 189.5,
      product: 'Çaykur Kamelya Siyah Çay 500 Gr',
      unit: '500 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 204.5,
      product: 'Çaykur Çay Çiçeği 500 Gr',
      unit: '500 GR',
    ),
  },
  'cay-500__lipton': {
    MarketId.migros: MarketIndexPrice(
      price: 279.95,
      product: 'Lipton Yellow Label Çay 500 Gr',
      unit: '500 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 289.95,
      product: 'Lipton Extra Dem Siyah Çay 500 Gr',
      unit: '500 GR',
    ),
  },
  'cikolata-100__lker': {
    MarketId.migros: MarketIndexPrice(
      price: 139.95,
      product: 'Ülker Sütlü Pul Çikolata 100 Gr',
      unit: '100 GR',
    ),
  },
  'cips-150__amigo': {
    MarketId.sok: MarketIndexPrice(
      price: 46.5,
      product: 'Amigo Düz Sade Patates Cipsi 150 Gr',
      unit: '150 GR',
    ),
  },
  'dis-macunu__colgate': {
    MarketId.bim: MarketIndexPrice(
      price: 147.0,
      product: 'Colgate Max White Diş Macunu 75 Ml',
      unit: '75 ML',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 135.0,
      product: 'Colgate Charcoal Diş Macunu 75 Ml',
      unit: '75 ML',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 170.0,
      product: 'Colgate Çocuk Diş Macunu 75 Ml',
      unit: '75 ML',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 459.95,
      product: 'Colgate Optik Beyaz Diş Macunu 75 Ml',
      unit: '75 ML',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 147.0,
      product: 'Colgate Max White Diş Macunu 75 Ml',
      unit: '75 ML',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 79.9,
      product: 'Colgate Barbie Batman Çocuk Diş Macunu 75 Ml',
      unit: '75 ML',
    ),
  },
  'dondurma-500__algida': {
    MarketId.bim: MarketIndexPrice(
      price: 200.0,
      product: 'Algida Maraş Usulü Sade Dondurma 500 Ml',
      unit: '500 ML',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 200.0,
      product: 'Algida Maraş Sade Dondurma 500 Ml',
      unit: '500 ML',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 225.0,
      product: 'Algida Maraş Usulü Bol Kaymaklı Dondurma 500 Ml',
      unit: '500 ML',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 200.0,
      product: 'Algida Maraş Usulü Sade Dondurma 500 Ml',
      unit: '500 ML',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 225.0,
      product: 'Algida Usta Usulü Çifte Dövülmüş Sade Dondurma 500 Ml',
      unit: '500 ML',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 200.0,
      product: 'Algida Maraş Usulü Sade Çikolata Dondurma 500 Ml',
      unit: '500 ML',
    ),
  },
  'ekmek-tam-bugday__uno': {
    MarketId.a101: MarketIndexPrice(
      price: 85.0,
      product: 'Uno Tam Buğday Unlu Tava Ekmek 450 Gr',
      unit: '450 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 90.0,
      product: 'Uno Ekşi Mayalı Tam Buğday Ekmek 450 Gr',
      unit: '450 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 90.0,
      product: 'Uno Ekşi Mayalı Tam Buğday Ekmek 450 Gr',
      unit: '450 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 74.5,
      product: 'Uno Tam Buğdaylı & Chia Tohumlu Ekmek 400 Gr',
      unit: '400 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 85.0,
      product: 'Uno Tam Buğday Ve Kavılca Unlu Ekmek 450 Gr',
      unit: '450 GR',
    ),
  },
  'filtre-kahve__mehmet-efendi': {
    MarketId.carrefour: MarketIndexPrice(
      price: 314.9,
      product: 'Mehmet Efendi Colombian Filtre Kahve 250 Gr',
      unit: '250 GR',
    ),
  },
  'findik-ici__amigo': {
    MarketId.sok: MarketIndexPrice(
      price: 188.0,
      product: 'Amigo Fındık İçi 150 Gr',
      unit: '150 GR',
    ),
  },
  'kahve-100__mehmet-efendi': {
    MarketId.hakmar: MarketIndexPrice(
      price: 97.5,
      product: 'Mehmet Efendi Türk Kahvesi 100 Gr',
      unit: '100 GR',
    ),
  },
  'kasar-500__icim': {
    MarketId.a101: MarketIndexPrice(
      price: 219.0,
      product: 'İçim Kaşar Peyniri 500 Gr',
      unit: '500 GR',
    ),
  },
  'kasar-500__mis': {
    MarketId.sok: MarketIndexPrice(
      price: 227.0,
      product: 'Mis Tam Yağlı Kaşar Peyniri 500 Gr',
      unit: '500 GR',
    ),
  },
  'kasar-500__muratbey': {
    MarketId.a101: MarketIndexPrice(
      price: 449.0,
      product: 'Muratbey Kaşar Peyniri 500 Gr',
      unit: '500 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 499.9,
      product: 'Muratbey Tam Yağlı Taze Kaşar Peyniri 500 Gr',
      unit: '500 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 299.95,
      product: 'Muratbey Tam Yağlı Taze Kaşar Peyniri 500 Gr',
      unit: '500 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 349.0,
      product: 'Muratbey Kaşar Peyniri 500 Gr',
      unit: '500 GR',
    ),
  },
  'kasar-500__sutas': {
    MarketId.a101: MarketIndexPrice(
      price: 219.0,
      product: 'Sütaş Kaşar Peyniri 500 Gr',
      unit: '500 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 299.0,
      product: 'Sütaş Kaşar Peyniri 500 Gr',
      unit: '500 GR',
    ),
  },
  'kek-162__eti': {
    MarketId.bim: MarketIndexPrice(
      price: 66.75,
      product: 'Eti Browni Mini Çikolatalı Kek 160 Gr',
      unit: '160 GR',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 45.0,
      product: 'Eti Paykek Mini Limonlu Haşhaşlı Kek 150 Gr',
      unit: '150 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 97.5,
      product: 'Eti Pronot Fındıklı Kakaolu Mini Kek 144 Gr',
      unit: '144 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 60.45,
      product: 'Eti Popkek Mini Bitter Çikolatalı Kek 162 Gr',
      unit: '162 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 69.0,
      product: 'Eti Browni Gold Çikolatalı Kek 9\'lu 180 Gr',
      unit: '180 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 97.0,
      product: 'Eti Pronot Glutensiz Kakaolu Mini Kek 144 Gr',
      unit: '144 GR',
    ),
  },
  'kek-162__olen': {
    MarketId.bim: MarketIndexPrice(
      price: 75.0,
      product: 'Şölen Luppo Karaorman Çikolata Kaplı Kek 182 Gr',
      unit: '182 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 79.0,
      product: 'Şölen Luppo Sandviç Kek Çilekli 184 Gr',
      unit: '184 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 79.0,
      product: 'Şölen Luppo Sandviç Kek Kakao/Sade 184 Gr',
      unit: '184 GR',
    ),
  },
  'kek-162__lker': {
    MarketId.bim: MarketIndexPrice(
      price: 79.0,
      product: 'Ülker Tart Çilek Jöleli Kek 180 Gr',
      unit: '180 GR',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 37.5,
      product: 'Ülker Dankek Lokmalık Kek Üzümlü 160 Gr',
      unit: '160 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 75.0,
      product: 'Ülker Dankek Tart Kek Çilekli 180 Gr',
      unit: '180 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 89.9,
      product: 'Ülker Tart Çilek Jöleli Kek 180 Gr',
      unit: '180 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 92.95,
      product: 'Ülker Tart Çilek Jöleli Kek 180 Gr',
      unit: '180 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 54.0,
      product: 'Ülker Kekstra Mini Çilekli Kek 150 Gr',
      unit: '150 GR',
    ),
  },
  'ketcap-500__bizim-vatan': {
    MarketId.sok: MarketIndexPrice(
      price: 39.9,
      product: 'Bizim Vatan Tatlı Ketçap 500 Gr',
      unit: '500 GR',
    ),
  },
  'kiyma-400__lezzetlim': {
    MarketId.sok: MarketIndexPrice(
      price: 330.0,
      product: 'Lezzetlim Dana Kıyma 400 Gr',
      unit: '400 GR',
    ),
  },
  'kofte-500__aytac': {
    MarketId.sok: MarketIndexPrice(
      price: 399.0,
      product: 'Aytaç Dondurulmuş Maydanozlu Dana Köfte 500 Gr',
      unit: '500 GR',
    ),
  },
  'kola-2-5l__coca-cola': {
    MarketId.a101: MarketIndexPrice(
      price: 90.0,
      product: 'Coca-Cola Kola 2.5 Lt',
      unit: '2.5 LT',
    ),
  },
  'kola-2-5l__cola-turka': {
    MarketId.a101: MarketIndexPrice(
      price: 70.0,
      product: 'Cola Turka Kola 2.5 Lt',
      unit: '2.5 LT',
    ),
  },
  'konserve-misir__bizim-vatan': {
    MarketId.sok: MarketIndexPrice(
      price: 46.5,
      product: 'Bizim Vatan Mısır Konservesi 400 Gr',
      unit: '400 GR',
    ),
  },
  'konserve-misir__superfresh': {
    MarketId.bim: MarketIndexPrice(
      price: 89.0,
      product: 'Superfresh Mısır Konservesi 600 Gr',
      unit: '600 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 89.0,
      product: 'SuperFresh Mısır Konservesi 3x200 Gr',
      unit: '600 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 54.95,
      product: 'SuperFresh Konserve Mısır 200 Gr',
      unit: '200 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 50.9,
      product: 'SuperFresh Konserve Mısır 200 Gr',
      unit: '200 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 89.0,
      product: 'Superfresh Konserve Mısır 3\'lü 600 Gr',
      unit: '600 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 89.0,
      product: 'SuperFresh Süt Mısır 3\'lü Avantaj Paketi 600 Gr',
      unit: '600 GR',
    ),
  },
  'kraker-82__eti': {
    MarketId.bim: MarketIndexPrice(
      price: 14.5,
      product: 'Eti Pizza Kraker 76 Gr',
      unit: '76 GR',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 13.0,
      product: 'Eti Çıtır Balık Kraker 70 Gr',
      unit: '70 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 22.75,
      product: 'Eti Mısırlı Balık Kraker 70 Gr',
      unit: '70 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 15.95,
      product: 'Eti Pizza Kraker 76 Gr',
      unit: '76 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 15.35,
      product: 'Eti Pizza Kraker 76 Gr',
      unit: '76 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 14.5,
      product: 'Eti Pizza Kraker 76 Gr',
      unit: '76 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 21.5,
      product: 'Eti Balık Kraker 85 Gr',
      unit: '85 GR',
    ),
  },
  'kraker-82__lker': {
    MarketId.bim: MarketIndexPrice(
      price: 9.75,
      product: 'Ülker Çizi Kraker 70 Gr',
      unit: '70 GR',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 9.5,
      product: 'Ülker Çubuk Kraker 80 Gr',
      unit: '80 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 17.0,
      product: 'Ülker Çizi Kraker Sade 70 Gr',
      unit: '70 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 14.5,
      product: 'Ülker Taç Kraker 76 Gr',
      unit: '76 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 14.95,
      product: 'Ülker Çubuk Kraker 80 Gr',
      unit: '80 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 14.75,
      product: 'Ülker Çizi Kraker 70 Gr',
      unit: '70 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 14.0,
      product: 'Ülker Çubuk Kraker 80 Gr',
      unit: '80 GR',
    ),
  },
  'labne-400__icim': {
    MarketId.bim: MarketIndexPrice(
      price: 149.0,
      product: 'İçim Labne 400 Gr',
      unit: '400 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 149.0,
      product: 'İçim Labne 400 Gr',
      unit: '400 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 156.75,
      product: 'İçim Labne Peynir 400 Gr',
      unit: '400 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 129.95,
      product: 'İçim Labne 400 Gr',
      unit: '400 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 145.0,
      product: 'İçim Labne Krem Peynir 400 Gr',
      unit: '400 GR',
    ),
  },
  'labne-400__mis': {
    MarketId.sok: MarketIndexPrice(
      price: 112.0,
      product: 'Mis Labne 400 Gr',
      unit: '400 GR',
    ),
  },
  'labne-400__pinar': {
    MarketId.migros: MarketIndexPrice(
      price: 165.9,
      product: 'Pınar Labne 400 Gr',
      unit: '400 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 170.95,
      product: 'Pınar Labne 400 Gr',
      unit: '400 GR',
    ),
  },
  'labne-400__sutas': {
    MarketId.a101: MarketIndexPrice(
      price: 139.5,
      product: 'Sütaş Sürülebilir Labne Peyniri 400 Gr',
      unit: '400 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 165.95,
      product: 'Sütaş Sürülebilir Labne Peyniri 400 Gr',
      unit: '400 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 129.5,
      product: 'Sütaş Sürülebilir Labne Peyniri 400 Gr',
      unit: '400 GR',
    ),
  },
  'maden-6x__beypazari': {
    MarketId.a101: MarketIndexPrice(
      price: 59.5,
      product: 'Beypazarı Doğal Maden Suyu 6x200 Ml',
      unit: '1.2 LT',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 66.0,
      product: 'Beypazarı Doğal Maden Suyu 6x200 Ml',
      unit: '1.2 LT',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 66.7,
      product: 'Beypazarı Doğal Maden Suyu 6x200 Ml',
      unit: '1.2 LT',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 69.5,
      product: 'Beypazarı Doğal Maden Suyu 6x200 Ml',
      unit: '1.2 LT',
    ),
  },
  'maden-6x__saka': {
    MarketId.migros: MarketIndexPrice(
      price: 71.5,
      product: 'Saka Doğal Maden Suyu 6x200 Ml',
      unit: '1.2 LT',
    ),
  },
  'maden-6x__uludag': {
    MarketId.migros: MarketIndexPrice(
      price: 66.0,
      product: 'Uludağ Doğal Maden Suyu 6x200 Ml',
      unit: '1.2 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 65.5,
      product: 'Uludağ Doğal Maden Suyu 6x200 Ml',
      unit: '1.2 LT',
    ),
  },
  'makarna-500__barilla': {
    MarketId.migros: MarketIndexPrice(
      price: 44.96,
      product: 'Barilla Linguine Yassı Spagetti Makarna 500 Gr',
      unit: '500 GR',
    ),
  },
  'makarna-500__filiz': {
    MarketId.a101: MarketIndexPrice(
      price: 33.5,
      product: 'Filiz Yassı Spagetti Makarna 500 Gr',
      unit: '500 GR',
    ),
  },
  'makarna-500__nuh-un-ankara': {
    MarketId.a101: MarketIndexPrice(
      price: 33.5,
      product: 'Nuh\'un Ankara Vitaminli Spagetti Makarna 500 Gr',
      unit: '500 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 34.95,
      product: 'Nuh\'un Ankara Spagetti Makarna 500 Gr',
      unit: '500 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 33.5,
      product: 'Nuh\'un Ankara Spagetti Makarna 500 Gr',
      unit: '500 GR',
    ),
  },
  'makarna-500__pastavilla': {
    MarketId.carrefour: MarketIndexPrice(
      price: 23.0,
      product: 'Pastavilla Spagetti Makarna 500 Gr',
      unit: '500 GR',
    ),
  },
  'makarna-penne__barilla': {
    MarketId.sok: MarketIndexPrice(
      price: 47.95,
      product: 'Barilla Penne Rigate Kalem 500 Gr',
      unit: '500 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 44.96,
      product: 'Barilla Pennette Kalem 500 Gr',
      unit: '500 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 44.95,
      product: 'Barilla Pennette Kalem 500 Gr',
      unit: '500 GR',
    ),
  },
  'mayonez-430__bizim-vatan': {
    MarketId.sok: MarketIndexPrice(
      price: 79.0,
      product: 'Bizim Vatan Mayonez 430 Gr',
      unit: '430 GR',
    ),
  },
  'mercimek-1kg__anadolu-mutfagi': {
    MarketId.sok: MarketIndexPrice(
      price: 49.5,
      product: 'Anadolu Mutfağı Kırmızı Mercimek 1 Kg',
      unit: '1 KG',
    ),
  },
  'mercimek-1kg__reis': {
    MarketId.migros: MarketIndexPrice(
      price: 179.95,
      product: 'Reis Kırmızı Mercimek 1 Kg',
      unit: '1 KG',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 256.95,
      product: 'Reis Kırmızı Mercimek 1 Kg',
      unit: '1 KG',
    ),
  },
  'mercimek-1kg__yayla': {
    MarketId.a101: MarketIndexPrice(
      price: 54.5,
      product: 'Yayla Kırmızı Yaprak Mercimek 1 Kg',
      unit: '1 KG',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 109.95,
      product: 'Yayla Kırmızı Mercimek 1 Kg',
      unit: '1 KG',
    ),
  },
  'nohut-1kg__anadolu-mutfagi': {
    MarketId.sok: MarketIndexPrice(
      price: 62.5,
      product: 'Anadolu Mutfağı Nohut 1 Kg',
      unit: '1 KG',
    ),
  },
  'nohut-1kg__reis': {
    MarketId.migros: MarketIndexPrice(
      price: 206.95,
      product: 'Reis Koçbaşı Nohut 1 Kg',
      unit: '1 KG',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 206.95,
      product: 'Reis Nohut 1 Kg',
      unit: '1 KG',
    ),
  },
  'nohut-1kg__yayla': {
    MarketId.migros: MarketIndexPrice(
      price: 134.95,
      product: 'Yayla Koçbaşı İri Boy Nohut 1 Kg',
      unit: '1 KG',
    ),
  },
  'peynir-500__bahcivan': {
    MarketId.a101: MarketIndexPrice(
      price: 145.0,
      product: 'Bahçıvan Süzme Peynir 500 Gr',
      unit: '500 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 144.9,
      product: 'Bahçıvan Süzme Peynir 500 Gr',
      unit: '500 GR',
    ),
  },
  'peynir-500__dost': {
    MarketId.bim: MarketIndexPrice(
      price: 105.0,
      product: 'Dost Süzme Beyaz Peynir 500 Gr',
      unit: '500 GR',
    ),
  },
  'peynir-500__icim': {
    MarketId.sok: MarketIndexPrice(
      price: 155.0,
      product: 'İçim Tam Yağlı Süzme Peynir 500 Gr',
      unit: '500 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 197.95,
      product: 'İçim Tam Yağlı Beyaz Peynir 500 Gr',
      unit: '500 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 149.95,
      product: 'İçim Beyaz Peynir 500 Gr',
      unit: '500 GR',
    ),
  },
  'peynir-500__mis': {
    MarketId.sok: MarketIndexPrice(
      price: 139.0,
      product: 'Mis Tam Yağlı Beyaz Peynir 500 Gr',
      unit: '500 GR',
    ),
  },
  'peynir-500__pinar': {
    MarketId.a101: MarketIndexPrice(
      price: 190.0,
      product: 'Pınar Süzme Beyaz Peynir 500 Gr',
      unit: '500 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 149.0,
      product: 'Pınar Süzme Peynir 500 Gr',
      unit: '500 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 189.5,
      product: 'Pınar Süzme Peynir 500 Gr',
      unit: '500 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 165.0,
      product: 'Pınar Süzme Peynir 500 Gr',
      unit: '500 GR',
    ),
  },
  'peynir-500__sutas': {
    MarketId.carrefour: MarketIndexPrice(
      price: 179.95,
      product: 'Sütaş Tam Yağlı Beyaz Peynir 500 Gr',
      unit: '500 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 145.0,
      product: 'Sütaş Süzme Peynir 500 Gr',
      unit: '500 GR',
    ),
  },
  'peynir-500__tahsildaroglu': {
    MarketId.migros: MarketIndexPrice(
      price: 299.9,
      product: 'Tahsildaroğlu Klasik İnek Peyniri 500 Gr',
      unit: '500 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 339.9,
      product: 'Tahsildaroğlu Klasik İnek Peyniri 500 Gr',
      unit: '500 GR',
    ),
  },
  'pilic-but__erpilic': {
    MarketId.bim: MarketIndexPrice(
      price: 85.0,
      product: 'Erpiliç Piliç Kalçalı But 1 Kg',
      unit: '1 KG',
    ),
  },
  'pilic-but__keskinoglu': {
    MarketId.sok: MarketIndexPrice(
      price: 125.0,
      product: 'Keskinoğlu Piliç Kalçalı But 1 Kg',
      unit: '1 KG',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 139.95,
      product: 'Keskinoğlu Piliç Kalçalı But 1 Kg',
      unit: '1 KG',
    ),
  },
  'pirinc-1kg__anadolu-mutfagi': {
    MarketId.sok: MarketIndexPrice(
      price: 83.5,
      product: 'Anadolu Mutfağı Baldo Pirinç 1 Kg',
      unit: '1 KG',
    ),
  },
  'pirinc-1kg__reis': {
    MarketId.carrefour: MarketIndexPrice(
      price: 107.99,
      product: 'Reis Osmancık Pirinç 1 Kg',
      unit: '1 KG',
    ),
  },
  'pirinc-1kg__yayla': {
    MarketId.a101: MarketIndexPrice(
      price: 69.5,
      product: 'Yayla Yerli Osmancık Pirinç 1 Kg',
      unit: '1 KG',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 104.95,
      product: 'Yayla Tok Tane Pirinç 1 Kg',
      unit: '1 KG',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 109.9,
      product: 'Yayla Basmati Pirinç 1 Kg',
      unit: '1 KG',
    ),
  },
  'salam-60__aytac': {
    MarketId.sok: MarketIndexPrice(
      price: 42.5,
      product: 'Aytaç Macar Salam 60 Gr',
      unit: '60 GR',
    ),
  },
  'salam-60__banvit': {
    MarketId.a101: MarketIndexPrice(
      price: 22.0,
      product: 'Banvit Dilimli Piliç Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 22.0,
      product: 'Banvit Bi Dilim Piliç Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 22.0,
      product: 'Banvit Dilimli Piliç Salam 60 Gr',
      unit: '60 GR',
    ),
  },
  'salam-60__maret': {
    MarketId.sok: MarketIndexPrice(
      price: 42.5,
      product: 'Maret Enfes Dana Macar Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 71.5,
      product: 'Maret Pratik Hindi Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 29.75,
      product: 'Maret Dilimli Pratik Hindi Salam 60 Gr',
      unit: '60 GR',
    ),
  },
  'salam-60__namet': {
    MarketId.sok: MarketIndexPrice(
      price: 56.5,
      product: 'Namet 7/24 Dana Macar Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 26.75,
      product: 'Namet 7/24 Hindi Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 27.9,
      product: 'Namet 7/24 Hindi Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 29.75,
      product: 'Namet Dilimli Hindi Füme Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 22.9,
      product: 'Namet 7/24 Hindi Salam 60 Gr',
      unit: '60 GR',
    ),
  },
  'salam-60__pinar': {
    MarketId.migros: MarketIndexPrice(
      price: 91.5,
      product: 'Pınar Aç Bitir Macar Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 91.9,
      product: 'Pınar Aç Bitir Macar Salam 60 Gr',
      unit: '60 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 44.5,
      product: 'Pınar Hindi Salam Büyük Dilimli 60 Gr',
      unit: '60 GR',
    ),
  },
  'salca-650__bizim-vatan': {
    MarketId.sok: MarketIndexPrice(
      price: 72.5,
      product: 'Bizim Vatan Acı Biber Salçası 650 Gr',
      unit: '650 GR',
    ),
  },
  'sampuan-400__elidor': {
    MarketId.bim: MarketIndexPrice(
      price: 149.0,
      product: 'Elidor Şampuan Çeşitleri 400 Ml',
      unit: '400 ML',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 199.0,
      product: 'Elidor Onarıcı Şampuan 400 Ml',
      unit: '400 ML',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 169.0,
      product: 'Elidor Keratin Şampuan 400 Ml',
      unit: '400 ML',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 154.95,
      product: 'Elidor Keratin Şampuan 400 Ml',
      unit: '400 ML',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 199.0,
      product: 'Elidor Şampuan 400 Ml',
      unit: '400 ML',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 199.0,
      product: 'Elidor Şampuan Çeşitleri 400 Ml',
      unit: '400 ML',
    ),
  },
  'sosis-190__aytac': {
    MarketId.sok: MarketIndexPrice(
      price: 135.0,
      product: 'Aytaç Sosis 190 Gr',
      unit: '190 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 227.92,
      product: 'Aytaç Dana Sosis 5li 190 Gr',
      unit: '190 GR',
    ),
  },
  'su-1-5l__kardelen': {
    MarketId.sok: MarketIndexPrice(
      price: 12.15,
      product: 'Kardelen Su 1.5 Lt',
      unit: '1.5 LT',
    ),
  },
  'su-5l__erikli': {
    MarketId.migros: MarketIndexPrice(
      price: 54.95,
      product: 'Erikli Su 5 Lt',
      unit: '5 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 84.5,
      product: 'Erikli Su 5 Lt',
      unit: '5 LT',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 49.5,
      product: 'Erikli Su 5 Lt',
      unit: '5 LT',
    ),
  },
  'su-5l__hayat': {
    MarketId.a101: MarketIndexPrice(
      price: 61.0,
      product: 'Hayat Su 5 Lt',
      unit: '5 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 52.75,
      product: 'Hayat Su 5 Lt',
      unit: '5 LT',
    ),
  },
  'su-5l__kardelen': {
    MarketId.sok: MarketIndexPrice(
      price: 36.0,
      product: 'Kardelen Su 5 Lt',
      unit: '5 LT',
    ),
  },
  'su-5l__nestl-pure-life': {
    MarketId.carrefour: MarketIndexPrice(
      price: 59.5,
      product: 'Nestlé Pure Life Su 5 Lt',
      unit: '5 LT',
    ),
  },
  'su-5l__saka': {
    MarketId.sok: MarketIndexPrice(
      price: 57.5,
      product: 'Saka Doğal Mineralli Su 5 Lt',
      unit: '5 LT',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 57.5,
      product: 'Saka Doğal Mineralli Su 5 Lt',
      unit: '5 LT',
    ),
  },
  'sucuk-250__aytac': {
    MarketId.sok: MarketIndexPrice(
      price: 209.0,
      product: 'Aytaç Dilimli Dana Sucuk Isıl İşlem 250 Gr',
      unit: '250 GR',
    ),
  },
  'sucuk-250__maret': {
    MarketId.sok: MarketIndexPrice(
      price: 189.0,
      product: 'Maret Enfes Isıl İşlem Sucuk 250 Gr',
      unit: '250 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 563.9,
      product: 'Maret Altın Sucuk 250 Gr',
      unit: '250 GR',
    ),
  },
  'sucuk-250__namet': {
    MarketId.migros: MarketIndexPrice(
      price: 299.0,
      product: 'Namet Dana Kasap Sucuk 250 Gr',
      unit: '250 GR',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 189.0,
      product: 'Namet Dana Kangal Sucuk 250 Gr',
      unit: '250 GR',
    ),
  },
  'sucuk-250__pinar': {
    MarketId.migros: MarketIndexPrice(
      price: 609.0,
      product: 'Pınar Gurme Sucuk 250 Gr',
      unit: '250 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 479.9,
      product: 'Pınar Gurme Sucuk 250 Gr',
      unit: '250 GR',
    ),
  },
  'sut-1l__dost': {
    MarketId.bim: MarketIndexPrice(
      price: 42.5,
      product: 'Dost %3.1 Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-1l__icim': {
    MarketId.a101: MarketIndexPrice(
      price: 55.0,
      product: 'İçim Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.sok: MarketIndexPrice(
      price: 54.9,
      product: 'İçim %3 Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 69.5,
      product: 'İçim Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 58.95,
      product: 'İçim Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-1l__mis': {
    MarketId.sok: MarketIndexPrice(
      price: 49.5,
      product: 'Mis %3.1 Yağlı UHT Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-1l__pinar': {
    MarketId.a101: MarketIndexPrice(
      price: 79.95,
      product: 'Pınar Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 79.95,
      product: 'Pınar Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 69.95,
      product: 'Pınar Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 80.0,
      product: 'Pınar Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-1l__sek': {
    MarketId.a101: MarketIndexPrice(
      price: 55.0,
      product: 'Sek Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 68.95,
      product: 'Sek Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 74.95,
      product: 'Sek Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-1l__sutas': {
    MarketId.carrefour: MarketIndexPrice(
      price: 69.95,
      product: 'Sütaş %3,5 Tam Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-yarim-1l__icim': {
    MarketId.migros: MarketIndexPrice(
      price: 59.75,
      product: 'İçim Yarım Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 49.95,
      product: 'İçim Yarım Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 57.5,
      product: 'İçim Yarım Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-yarim-1l__mis': {
    MarketId.sok: MarketIndexPrice(
      price: 41.0,
      product: 'Mis Yarım Yağlı Uht Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-yarim-1l__pinar': {
    MarketId.a101: MarketIndexPrice(
      price: 65.5,
      product: 'Pınar Yarım Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-yarim-1l__sek': {
    MarketId.a101: MarketIndexPrice(
      price: 52.5,
      product: 'Sek Yarım Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 64.95,
      product: 'Sek Yarım Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'sut-yarim-1l__sutas': {
    MarketId.carrefour: MarketIndexPrice(
      price: 67.25,
      product: 'Sütaş Yarım Yağlı Süt 1 Lt',
      unit: '1 LT',
    ),
  },
  'tavuk-1kg__gedik': {
    MarketId.sok: MarketIndexPrice(
      price: 249.0,
      product: 'Gedik Piliç But Pirzola 1 Kg',
      unit: '1 KG',
    ),
  },
  'tereyag-500__icim': {
    MarketId.migros: MarketIndexPrice(
      price: 478.95,
      product: 'İçim Tereyağı 500 Gr',
      unit: '500 GR',
    ),
  },
  'tereyag-500__mis': {
    MarketId.sok: MarketIndexPrice(
      price: 279.0,
      product: 'Mis Tereyağı 500 Gr',
      unit: '500 GR',
    ),
  },
  'ton-2x160__bizim-vatan': {
    MarketId.sok: MarketIndexPrice(
      price: 121.0,
      product: 'Bizim Vatan Ton Balığı 2x160 Gr',
      unit: '320 GR',
    ),
  },
  'tuvalet-16__selpak': {
    MarketId.carrefour: MarketIndexPrice(
      price: 169.9,
      product: 'Selpak Kaşmir Katkılı Tuvalet Kağıdı 16 Adet',
      unit: null,
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 199.0,
      product: 'Selpak 3 Katlı Tuvalet Kağıdı 16 Adet',
      unit: null,
    ),
  },
  'tuvalet-16__solo': {
    MarketId.a101: MarketIndexPrice(
      price: 154.9,
      product: 'Solo Bambu Katkılı Tuvalet Kağıdı 16 Adet',
      unit: null,
    ),
  },
  'tuz-500__billur': {
    MarketId.a101: MarketIndexPrice(
      price: 54.5,
      product: 'Billur Tuz İyotlu Sofra Tuzu 500 Gr',
      unit: '500 GR',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 41.96,
      product: 'Billur Tuz İyotlu Sofra Tuzu 500 Gr',
      unit: '500 GR',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 27.0,
      product: 'Billur Tuz İyotlu Sofra Tuzu 500 Gr',
      unit: '500 GR',
    ),
  },
  'un-5kg__piyale': {
    MarketId.sok: MarketIndexPrice(
      price: 135.0,
      product: 'Piyale Un 5 Kg',
      unit: '5 KG',
    ),
  },
  'yogurt-1kg__eker': {
    MarketId.migros: MarketIndexPrice(
      price: 142.5,
      product: 'Eker Kaymaklı Tava Yoğurt 1 Kg',
      unit: '1 KG',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 119.95,
      product: 'Eker Kaymaklı Tava Yoğurt 1 Kg',
      unit: '1 KG',
    ),
  },
  'yogurt-1kg__icim': {
    MarketId.sok: MarketIndexPrice(
      price: 85.9,
      product: 'İçim Tam Yağlı Kaymaksız Yoğurt 1 Kg',
      unit: '1 KG',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 89.95,
      product: 'İçim Doğal Yoğurt 1 Kg',
      unit: '1 KG',
    ),
  },
  'yogurt-1kg__mis': {
    MarketId.sok: MarketIndexPrice(
      price: 79.9,
      product: 'Mis Kaymaklı Yoğurt 1 Kg',
      unit: '1 KG',
    ),
  },
  'yogurt-1kg__pinar': {
    MarketId.carrefour: MarketIndexPrice(
      price: 150.9,
      product: 'Pınar Organik Yoğurt 1 Kg',
      unit: '1 KG',
    ),
  },
  'yogurt-1kg__sutas': {
    MarketId.sok: MarketIndexPrice(
      price: 89.9,
      product: 'Sütaş Kaymaksız Yoğurt 1 Kg',
      unit: '1 KG',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 89.95,
      product: 'Sütaş Yoğurt 1 Kg',
      unit: '1 KG',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 101.95,
      product: 'Sütaş Kaymaksız Yoğurt 1 Kg',
      unit: '1 KG',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 87.5,
      product: 'Sütaş Kaymaksız Yoğurt 1 Kg',
      unit: '1 KG',
    ),
    MarketId.tarimKredi: MarketIndexPrice(
      price: 79.5,
      product: 'Sütaş Kaymaksız Yoğurt 1 Kg',
      unit: '1 KG',
    ),
  },
  'yumurta-15__anadolu-iftligi': {
    MarketId.sok: MarketIndexPrice(
      price: 64.9,
      product: 'Anadolu Çiftliği Yumurta 63-72 Gr 15 Adet',
      unit: null,
    ),
  },
  'yumurta-30__anadolu-iftligi': {
    MarketId.sok: MarketIndexPrice(
      price: 129.0,
      product: 'Anadolu Çiftliği Yumurta 53-62 Gr 30 Adet',
      unit: null,
    ),
  },
  'zeytin-500__lio': {
    MarketId.sok: MarketIndexPrice(
      price: 155.0,
      product: 'Lio Salamura Siyah Zeytin 201-260 500 Gr',
      unit: '500 GR',
    ),
  },
  'zeytinyagi-1l__komili': {
    MarketId.bim: MarketIndexPrice(
      price: 290.0,
      product: 'Komili Riviera Zeytinyağı 1 Lt',
      unit: '1 LT',
    ),
    MarketId.migros: MarketIndexPrice(
      price: 409.95,
      product: 'Komili Riviera Yemeklik Zeytinyağı 1 Lt',
      unit: '1 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 399.95,
      product: 'Komili Riviera Zeytinyağı 1 Lt',
      unit: '1 LT',
    ),
    MarketId.hakmar: MarketIndexPrice(
      price: 359.0,
      product: 'Komili Yumuşak Sızma Zeytinyağı 1 Lt',
      unit: '1 LT',
    ),
  },
  'zeytinyagi-1l__lio': {
    MarketId.sok: MarketIndexPrice(
      price: 310.0,
      product: 'Lio Sızma Zeytinyağı 1 Lt',
      unit: '1 LT',
    ),
  },
  'zeytinyagi-1l__yudum': {
    MarketId.bim: MarketIndexPrice(
      price: 249.0,
      product: 'Yudum Egemden Sızma Zeytinyağı 1 Lt',
      unit: '1 LT',
    ),
    MarketId.a101: MarketIndexPrice(
      price: 299.0,
      product: 'Yudum Egemden Riviera Zeytinyağı 1 Lt',
      unit: '1 LT',
    ),
    MarketId.carrefour: MarketIndexPrice(
      price: 410.9,
      product: 'Yudum Egemden Riviera Zeytinyağı 1 Lt',
      unit: '1 LT',
    ),
  },
};

/// Bir tipte çeşidi güvenilir biçimde indekslenmiş marketler.
///
/// Bu marketlerde aranan marka + birim indekste yoksa satır "yok" sayılır;
/// indeksi zayıf marketlerde ise eksiklik kanıt değildir. Eşik: en az
/// 4 farklı marka.
const marketPriceIndexAssortment = <String, Set<MarketId>>{
  'aycicek-5l': {MarketId.a101, MarketId.hakmar},
  'biskuvi-102': {MarketId.bim, MarketId.a101, MarketId.sok, MarketId.migros, MarketId.carrefour, MarketId.hakmar, MarketId.tarimKredi},
  'bulgur-1kg': {MarketId.carrefour},
  'cay-1000': {MarketId.bim, MarketId.a101, MarketId.sok, MarketId.migros, MarketId.carrefour, MarketId.hakmar},
  'cay-500': {MarketId.migros, MarketId.carrefour},
  'cikolata-100': {MarketId.migros},
  'cop-torbasi': {MarketId.migros, MarketId.carrefour},
  'dis-macunu': {MarketId.a101, MarketId.migros, MarketId.carrefour},
  'dondurma-500': {MarketId.carrefour},
  'dus-jeli': {MarketId.migros},
  'ekmek-beyaz': {MarketId.migros, MarketId.carrefour},
  'filtre-kahve': {MarketId.sok, MarketId.migros, MarketId.carrefour},
  'kahve-100': {MarketId.a101, MarketId.sok, MarketId.migros, MarketId.carrefour, MarketId.tarimKredi},
  'kasar-500': {MarketId.a101},
  'kek-162': {MarketId.bim, MarketId.carrefour, MarketId.hakmar},
  'kofte-500': {MarketId.bim},
  'kraker-82': {MarketId.a101, MarketId.carrefour},
  'maden-6x': {MarketId.bim, MarketId.a101, MarketId.migros, MarketId.carrefour},
  'makarna-500': {MarketId.a101, MarketId.migros, MarketId.carrefour},
  'mercimek-1kg': {MarketId.migros, MarketId.carrefour},
  'nohut-1kg': {MarketId.migros, MarketId.carrefour},
  'patates-1kg': {MarketId.carrefour, MarketId.hakmar},
  'peynir-500': {MarketId.bim, MarketId.a101, MarketId.migros, MarketId.carrefour, MarketId.hakmar},
  'pirinc-1kg': {MarketId.a101, MarketId.migros, MarketId.carrefour},
  'salam-60': {MarketId.a101, MarketId.sok, MarketId.hakmar},
  'sampuan-400': {MarketId.a101, MarketId.migros},
  'seker-1kg': {MarketId.bim},
  'su-1-5l': {MarketId.migros, MarketId.carrefour},
  'su-5l': {MarketId.a101, MarketId.sok, MarketId.migros, MarketId.carrefour},
  'sucuk-250': {MarketId.sok, MarketId.migros, MarketId.hakmar},
  'sut-1l': {MarketId.a101, MarketId.migros, MarketId.carrefour},
  'sut-yarim-1l': {MarketId.a101, MarketId.carrefour},
  'tuvalet-16': {MarketId.carrefour},
  'tuz-500': {MarketId.carrefour},
  'un-5kg': {MarketId.bim},
  'yogurt-1kg': {MarketId.migros, MarketId.carrefour},
  'yumurta-15': {MarketId.tarimKredi},
  'zeytin-500': {MarketId.migros},
  'zeytinyagi-1l': {MarketId.bim, MarketId.migros, MarketId.carrefour},
};
