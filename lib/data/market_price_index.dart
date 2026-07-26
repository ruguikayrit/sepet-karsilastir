/// marketfiyati.org.tr (TÜBİTAK) fiyat indeksinden alınan market fiyatları.
///
/// Servis yedi zincirin kasa fiyatlarını yayınlar: BİM, A101, Şok, Migros,
/// CarrefourSA, Hakmar Express ve Tarım Kredi (KOOP) Market.
///
/// Her kayıt `ürün tipi__marka` kimliğine bağlıdır ve **tek bir ürünün**
/// zincirlere göre fiyatını tutar: satır her markette aynı marka, aynı
/// gramaj ve aynı çeşidi gösterir. Gramaj katalogdaki tipin gramajıyla
/// birebir aynıdır; tutmayan eşleşmeler indekse alınmaz.
///
/// Çekim: 2026-07-26 · İstanbul depoları · 124 ürün,
/// 203 market fiyatı. Fiyat, zincir birden fazla şube listeliyorsa
/// şube fiyatlarının medyanıdır.
library;

import '../models/market.dart';

/// Bir ürünün indekste yayınlanan market fiyatları.
class MarketIndexEntry {
  const MarketIndexEntry({
    required this.product,
    required this.prices,
    this.unit,
  });

  /// İndekste listelenen ürün adı (marka + gramaj doğrulaması için).
  final String product;

  /// Zincir -> raf fiyatı. Hepsi aynı ürünün fiyatıdır.
  final Map<MarketId, double> prices;

  /// İndeksin bildirdiği gramaj/hacim (ör. `500 GR`).
  final String? unit;
}

const marketPriceIndexSource = 'marketfiyati.org.tr';
const marketPriceIndexFetchedAt = '2026-07-26';
const marketPriceIndexRegion = 'İstanbul';

/// `ürün tipi__marka` -> indekste doğrulanmış market fiyatları.
const marketPriceIndex = <String, MarketIndexEntry>{
  'aycicek-1l__evin': MarketIndexEntry(
    product: 'Evin Ayçiçek Yağı 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.sok: 122.0,
    },
  ),
  'aycicek-1l__komili': MarketIndexEntry(
    product: 'Komili Ayçiçek Yağı 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.migros: 199.95,
    },
  ),
  'aycicek-1l__yudum': MarketIndexEntry(
    product: 'Yudum Ayçiçek Yağı 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.migros: 209.95,
      MarketId.carrefour: 149.9,
    },
  ),
  'aycicek-5l__evin': MarketIndexEntry(
    product: 'Evin Ayçiçek Yağı 5 Lt',
    unit: '5 LT',
    prices: {
      MarketId.sok: 469.0,
    },
  ),
  'aycicek-5l__komili': MarketIndexEntry(
    product: 'Komili Ayçiçek Yağı 5 Lt',
    unit: '5 LT',
    prices: {
      MarketId.a101: 544.5,
      MarketId.migros: 544.95,
    },
  ),
  'aycicek-5l__yudum': MarketIndexEntry(
    product: 'Yudum Ayçiçek Yağı Köşeli Pet 5 Lt',
    unit: '5 LT',
    prices: {
      MarketId.migros: 549.95,
      MarketId.carrefour: 469.0,
    },
  ),
  'ayran-285__mis': MarketIndexEntry(
    product: 'Mis Bardak Ayran Tam Yağlı 285 Ml',
    unit: '285 ML',
    prices: {
      MarketId.sok: 13.5,
    },
  ),
  'bebek-bezi__sleepy': MarketIndexEntry(
    product: 'Sleepy Natural Jumbo Paket 5 No Junior Bebek Bezi 40 Adet',
    unit: null,
    prices: {
      MarketId.migros: 299.95,
    },
  ),
  'bulasik-1500__bingo': MarketIndexEntry(
    product: 'Bingo Limonlu Elde Bulaşık Deterjanı 1.5 Lt',
    unit: '1.5 LT',
    prices: {
      MarketId.migros: 229.95,
    },
  ),
  'bulgur-1kg__anadolu-mutfagi': MarketIndexEntry(
    product: 'Anadolu Mutfağı Köftelik Bulgur 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.sok: 34.0,
    },
  ),
  'bulgur-1kg__reis': MarketIndexEntry(
    product: 'Reis Köftelik Bulgur 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.carrefour: 79.95,
    },
  ),
  'bulgur-1kg__yayla': MarketIndexEntry(
    product: 'Yayla Köftelik Bulgur 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.migros: 49.95,
    },
  ),
  'cay-1000__caykur': MarketIndexEntry(
    product: 'Çaykur Tiryaki Çay 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.a101: 356.0,
      MarketId.sok: 356.0,
      MarketId.migros: 389.95,
      MarketId.tarimKredi: 345.0,
    },
  ),
  'cay-1000__dogus': MarketIndexEntry(
    product: 'Doğuş Filiz Çayı 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.a101: 325.0,
      MarketId.sok: 325.0,
      MarketId.migros: 339.95,
    },
  ),
  'cay-1000__lipton': MarketIndexEntry(
    product: 'Lipton Doğu Karadeniz Çayı 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.bim: 369.0,
      MarketId.a101: 369.0,
      MarketId.sok: 369.0,
      MarketId.migros: 374.95,
      MarketId.carrefour: 244.99,
    },
  ),
  'cay-1000__ofcay': MarketIndexEntry(
    product: 'Ofçay Tiryaki Siyah Çay 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.carrefour: 313.0,
      MarketId.hakmar: 265.0,
    },
  ),
  'cay-500__caykur': MarketIndexEntry(
    product: 'Çaykur Filiz Çay 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.a101: 225.0,
      MarketId.sok: 225.0,
      MarketId.migros: 224.95,
    },
  ),
  'cay-500__lipton': MarketIndexEntry(
    product: 'Lipton Extra Dem Siyah Çay 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.migros: 289.95,
      MarketId.carrefour: 289.95,
    },
  ),
  'cikolata-100__ulker': MarketIndexEntry(
    product: 'Ülker Sütlü Pul Çikolata 100 Gr',
    unit: '100 GR',
    prices: {
      MarketId.migros: 139.95,
    },
  ),
  'cips-150__amigo': MarketIndexEntry(
    product: 'Amigo Düz Sade Patates Cipsi 150 Gr',
    unit: '150 GR',
    prices: {
      MarketId.sok: 46.5,
    },
  ),
  'dis-macunu__colgate': MarketIndexEntry(
    product: 'Colgate Max White Diş Macunu 75 Ml',
    unit: '75 ML',
    prices: {
      MarketId.bim: 147.0,
      MarketId.a101: 147.0,
      MarketId.sok: 147.0,
      MarketId.hakmar: 147.0,
    },
  ),
  'dondurma-500__algida': MarketIndexEntry(
    product: 'Algida Maraş Usulü Sade Çikolata Dondurma 500 Ml',
    unit: '500 ML',
    prices: {
      MarketId.a101: 200.0,
      MarketId.migros: 200.0,
      MarketId.hakmar: 200.0,
    },
  ),
  'ekmek-tam-bugday__uno': MarketIndexEntry(
    product: 'Uno Tam Buğday Ve Kavılca Unlu Ekmek 450 Gr',
    unit: '450 GR',
    prices: {
      MarketId.migros: 90.0,
      MarketId.carrefour: 90.0,
      MarketId.tarimKredi: 85.0,
    },
  ),
  'filtre-kahve__mehmet-efendi': MarketIndexEntry(
    product: 'Mehmet Efendi Colombian Filtre Kahve 250 Gr',
    unit: '250 GR',
    prices: {
      MarketId.carrefour: 314.9,
    },
  ),
  'findik-ici__amigo': MarketIndexEntry(
    product: 'Amigo Fındık İçi 150 Gr',
    unit: '150 GR',
    prices: {
      MarketId.sok: 188.0,
    },
  ),
  'kahve-100__mehmet-efendi': MarketIndexEntry(
    product: 'Mehmet Efendi Türk Kahvesi 100 Gr',
    unit: '100 GR',
    prices: {
      MarketId.hakmar: 97.5,
    },
  ),
  'kasar-500__icim': MarketIndexEntry(
    product: 'İçim Kaşar Peyniri 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.a101: 219.0,
    },
  ),
  'kasar-500__mis': MarketIndexEntry(
    product: 'Mis Tam Yağlı Kaşar Peyniri 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.sok: 227.0,
    },
  ),
  'kasar-500__muratbey': MarketIndexEntry(
    product: 'Muratbey Kaşar Peyniri 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.a101: 449.0,
      MarketId.hakmar: 349.0,
    },
  ),
  'kasar-500__sutas': MarketIndexEntry(
    product: 'Sütaş Kaşar Peyniri 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.a101: 219.0,
      MarketId.sok: 299.0,
    },
  ),
  'kek-162__eti': MarketIndexEntry(
    product: 'Eti Popkek Mini Bitter Çikolatalı Kek 162 Gr',
    unit: '162 GR',
    prices: {
      MarketId.carrefour: 60.45,
    },
  ),
  'kek-162__ulker': MarketIndexEntry(
    product: 'Ülker Olala Mini Sufle Çikolatalı Kek 162 Gr',
    unit: '162 GR',
    prices: {
      MarketId.bim: 47.5,
      MarketId.a101: 47.5,
      MarketId.migros: 69.9,
      MarketId.carrefour: 44.0,
    },
  ),
  'ketcap-500__bizim-vatan': MarketIndexEntry(
    product: 'Bizim Vatan Tatlı Ketçap 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.sok: 39.9,
    },
  ),
  'kiyma-400__lezzetlim': MarketIndexEntry(
    product: 'Lezzetlim Dana Kıyma 400 Gr',
    unit: '400 GR',
    prices: {
      MarketId.sok: 330.0,
    },
  ),
  'kofte-500__aytac': MarketIndexEntry(
    product: 'Aytaç Dondurulmuş Maydanozlu Dana Köfte 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.sok: 399.0,
    },
  ),
  'kofte-500__erpilic': MarketIndexEntry(
    product: 'Erpiliç Göynük Piliç Köfte 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.bim: 89.0,
    },
  ),
  'kola-2-5l__coca-cola': MarketIndexEntry(
    product: 'Coca-Cola Kola 2.5 Lt',
    unit: '2.5 LT',
    prices: {
      MarketId.a101: 90.0,
    },
  ),
  'kola-2-5l__cola-turka': MarketIndexEntry(
    product: 'Cola Turka Kola 2.5 Lt',
    unit: '2.5 LT',
    prices: {
      MarketId.a101: 70.0,
    },
  ),
  'konserve-misir__superfresh': MarketIndexEntry(
    product: 'Superfresh Konserve Mısır 600 Gr',
    unit: '600 GR',
    prices: {
      MarketId.migros: 90.95,
      MarketId.carrefour: 89.9,
    },
  ),
  'kraker-82__ulker': MarketIndexEntry(
    product: 'Ülker Çiziviç Peynirli Sandviç Kraker 82 Gr',
    unit: '82 GR',
    prices: {
      MarketId.sok: 22.5,
      MarketId.carrefour: 23.75,
    },
  ),
  'labne-400__icim': MarketIndexEntry(
    product: 'İçim Labne 400 Gr',
    unit: '400 GR',
    prices: {
      MarketId.bim: 149.0,
      MarketId.sok: 149.0,
      MarketId.carrefour: 129.95,
    },
  ),
  'labne-400__mis': MarketIndexEntry(
    product: 'Mis Labne 400 Gr',
    unit: '400 GR',
    prices: {
      MarketId.sok: 112.0,
    },
  ),
  'labne-400__pinar': MarketIndexEntry(
    product: 'Pınar Labne 400 Gr',
    unit: '400 GR',
    prices: {
      MarketId.migros: 165.9,
      MarketId.carrefour: 170.95,
    },
  ),
  'labne-400__sutas': MarketIndexEntry(
    product: 'Sütaş Sürülebilir Labne Peyniri 400 Gr',
    unit: '400 GR',
    prices: {
      MarketId.a101: 139.5,
      MarketId.carrefour: 165.95,
      MarketId.tarimKredi: 129.5,
    },
  ),
  'maden-6x__beypazari': MarketIndexEntry(
    product: 'Beypazarı Doğal Maden Suyu 6x200 Ml',
    unit: '1.2 LT',
    prices: {
      MarketId.a101: 59.5,
      MarketId.sok: 66.0,
      MarketId.migros: 66.7,
      MarketId.hakmar: 69.5,
    },
  ),
  'maden-6x__saka': MarketIndexEntry(
    product: 'Saka Doğal Maden Suyu 6x200 Ml',
    unit: '1.2 LT',
    prices: {
      MarketId.migros: 71.5,
    },
  ),
  'maden-6x__uludag': MarketIndexEntry(
    product: 'Uludağ Doğal Maden Suyu 6x200 Ml',
    unit: '1.2 LT',
    prices: {
      MarketId.migros: 66.0,
      MarketId.carrefour: 65.5,
    },
  ),
  'makarna-500__barilla': MarketIndexEntry(
    product: 'Barilla Linguine Yassı Spagetti Makarna 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.migros: 44.96,
    },
  ),
  'makarna-500__filiz': MarketIndexEntry(
    product: 'Filiz Yassı Spagetti Makarna 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.a101: 33.5,
    },
  ),
  'makarna-500__nuh-un-ankara': MarketIndexEntry(
    product: 'Nuh\'un Ankara Spagetti Makarna 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.migros: 34.95,
      MarketId.hakmar: 33.5,
    },
  ),
  'makarna-500__pastavilla': MarketIndexEntry(
    product: 'Pastavilla Spagetti Makarna 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.carrefour: 23.0,
    },
  ),
  'makarna-penne__barilla': MarketIndexEntry(
    product: 'Barilla Pennette Kalem 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.migros: 44.96,
      MarketId.carrefour: 44.95,
    },
  ),
  'mayonez-430__bizim-vatan': MarketIndexEntry(
    product: 'Bizim Vatan Mayonez 430 Gr',
    unit: '430 GR',
    prices: {
      MarketId.sok: 79.0,
    },
  ),
  'mercimek-1kg__anadolu-mutfagi': MarketIndexEntry(
    product: 'Anadolu Mutfağı Kırmızı Mercimek 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.sok: 49.5,
    },
  ),
  'mercimek-1kg__reis': MarketIndexEntry(
    product: 'Reis Kırmızı Mercimek 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.migros: 179.95,
      MarketId.carrefour: 256.95,
    },
  ),
  'mercimek-1kg__yayla': MarketIndexEntry(
    product: 'Yayla Kırmızı Mercimek 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.migros: 109.95,
    },
  ),
  'nohut-1kg__anadolu-mutfagi': MarketIndexEntry(
    product: 'Anadolu Mutfağı Nohut 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.sok: 62.5,
    },
  ),
  'nohut-1kg__reis': MarketIndexEntry(
    product: 'Reis Nohut 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.carrefour: 206.95,
    },
  ),
  'nohut-1kg__yayla': MarketIndexEntry(
    product: 'Yayla Koçbaşı İri Boy Nohut 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.migros: 134.95,
    },
  ),
  'peynir-500__bahcivan': MarketIndexEntry(
    product: 'Bahçıvan Süzme Peynir 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.a101: 145.0,
      MarketId.migros: 144.9,
    },
  ),
  'peynir-500__dost': MarketIndexEntry(
    product: 'Dost Süzme Beyaz Peynir 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.bim: 105.0,
    },
  ),
  'peynir-500__icim': MarketIndexEntry(
    product: 'İçim Tam Yağlı Süzme Peynir 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.sok: 155.0,
      MarketId.migros: 149.0,
      MarketId.carrefour: 129.95,
    },
  ),
  'peynir-500__mis': MarketIndexEntry(
    product: 'Mis Tam Yağlı Beyaz Peynir 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.sok: 139.0,
    },
  ),
  'peynir-500__pinar': MarketIndexEntry(
    product: 'Pınar Süzme Peynir 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.migros: 149.0,
      MarketId.carrefour: 189.5,
      MarketId.hakmar: 165.0,
    },
  ),
  'peynir-500__sutas': MarketIndexEntry(
    product: 'Sütaş Süzme Peynir 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.carrefour: 159.95,
      MarketId.tarimKredi: 145.0,
    },
  ),
  'peynir-500__tahsildaroglu': MarketIndexEntry(
    product: 'Tahsildaroğlu Klasik İnek Peyniri 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.migros: 299.9,
      MarketId.carrefour: 339.9,
    },
  ),
  'pilic-but__erpilic': MarketIndexEntry(
    product: 'Erpiliç Piliç Kalçalı But 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.bim: 85.0,
    },
  ),
  'pilic-but__keskinoglu': MarketIndexEntry(
    product: 'Keskinoğlu Piliç Kalçalı But 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.sok: 125.0,
      MarketId.migros: 139.95,
    },
  ),
  'pirinc-1kg__anadolu-mutfagi': MarketIndexEntry(
    product: 'Anadolu Mutfağı Baldo Pirinç 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.sok: 83.5,
    },
  ),
  'pirinc-1kg__reis': MarketIndexEntry(
    product: 'Reis Osmancık Pirinç 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.migros: 179.95,
      MarketId.carrefour: 107.99,
    },
  ),
  'pirinc-1kg__yayla': MarketIndexEntry(
    product: 'Yayla Yerli Osmancık Pirinç 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.a101: 69.5,
      MarketId.migros: 121.95,
    },
  ),
  'salam-60__aytac': MarketIndexEntry(
    product: 'Aytaç Macar Salam 60 Gr',
    unit: '60 GR',
    prices: {
      MarketId.sok: 42.5,
    },
  ),
  'salam-60__banvit': MarketIndexEntry(
    product: 'Banvit Dilimli Piliç Salam 60 Gr',
    unit: '60 GR',
    prices: {
      MarketId.a101: 22.0,
      MarketId.hakmar: 22.0,
    },
  ),
  'salam-60__maret': MarketIndexEntry(
    product: 'Maret Pratik Hindi Salam 60 Gr',
    unit: '60 GR',
    prices: {
      MarketId.carrefour: 71.5,
    },
  ),
  'salam-60__namet': MarketIndexEntry(
    product: 'Namet 7/24 Hindi Salam 60 Gr',
    unit: '60 GR',
    prices: {
      MarketId.migros: 26.75,
      MarketId.carrefour: 27.9,
      MarketId.tarimKredi: 22.9,
    },
  ),
  'salam-60__pinar': MarketIndexEntry(
    product: 'Pınar Aç Bitir Macar Salam 60 Gr',
    unit: '60 GR',
    prices: {
      MarketId.migros: 91.5,
      MarketId.carrefour: 91.9,
    },
  ),
  'salca-650__bizim-vatan': MarketIndexEntry(
    product: 'Bizim Vatan Acı Biber Salçası 650 Gr',
    unit: '650 GR',
    prices: {
      MarketId.sok: 72.5,
    },
  ),
  'sampuan-400__elidor': MarketIndexEntry(
    product: 'Elidor Keratin Şampuan 400 Ml',
    unit: '400 ML',
    prices: {
      MarketId.sok: 169.0,
      MarketId.migros: 154.95,
    },
  ),
  'sosis-190__aytac': MarketIndexEntry(
    product: 'Aytaç Sosis 190 Gr',
    unit: '190 GR',
    prices: {
      MarketId.sok: 135.0,
    },
  ),
  'su-1-5l__erikli': MarketIndexEntry(
    product: 'Erikli Su 1.5 Lt',
    unit: '1.5 LT',
    prices: {
      MarketId.migros: 38.95,
      MarketId.carrefour: 47.5,
    },
  ),
  'su-1-5l__hayat': MarketIndexEntry(
    product: 'Hayat Su 1.5 Lt',
    unit: '1.5 LT',
    prices: {
      MarketId.a101: 35.0,
    },
  ),
  'su-1-5l__kardelen': MarketIndexEntry(
    product: 'Kardelen Su 1.5 Lt',
    unit: '1.5 LT',
    prices: {
      MarketId.sok: 12.15,
    },
  ),
  'su-1-5l__nestle-pure-life': MarketIndexEntry(
    product: 'Nestlé Pure Life Su 1.5 Lt',
    unit: '1.5 LT',
    prices: {
      MarketId.migros: 31.75,
    },
  ),
  'su-1-5l__saka': MarketIndexEntry(
    product: 'Saka Doğal Mineralli Su 1.5 Lt',
    unit: '1.5 LT',
    prices: {
      MarketId.sok: 34.9,
      MarketId.migros: 34.95,
    },
  ),
  'su-5l__erikli': MarketIndexEntry(
    product: 'Erikli Su 5 Lt',
    unit: '5 LT',
    prices: {
      MarketId.migros: 54.95,
      MarketId.carrefour: 84.5,
      MarketId.hakmar: 49.5,
    },
  ),
  'su-5l__hayat': MarketIndexEntry(
    product: 'Hayat Su 5 Lt',
    unit: '5 LT',
    prices: {
      MarketId.a101: 61.0,
      MarketId.carrefour: 52.75,
    },
  ),
  'su-5l__kardelen': MarketIndexEntry(
    product: 'Kardelen Su 5 Lt',
    unit: '5 LT',
    prices: {
      MarketId.sok: 36.0,
    },
  ),
  'su-5l__nestle-pure-life': MarketIndexEntry(
    product: 'Nestlé Pure Life Su 5 Lt',
    unit: '5 LT',
    prices: {
      MarketId.carrefour: 59.5,
    },
  ),
  'su-5l__saka': MarketIndexEntry(
    product: 'Saka Doğal Mineralli Su 5 Lt',
    unit: '5 LT',
    prices: {
      MarketId.sok: 57.5,
      MarketId.migros: 57.5,
    },
  ),
  'sucuk-250__aytac': MarketIndexEntry(
    product: 'Aytaç Dilimli Dana Sucuk Isıl İşlem 250 Gr',
    unit: '250 GR',
    prices: {
      MarketId.sok: 209.0,
    },
  ),
  'sucuk-250__banvit': MarketIndexEntry(
    product: 'Banvit Piliç Kangal Sucuk 250 Gr',
    unit: '250 GR',
    prices: {
      MarketId.sok: 67.5,
    },
  ),
  'sucuk-250__keskinoglu': MarketIndexEntry(
    product: 'Keskinoğlu Piliç Sucuk 250 Gr',
    unit: '250 GR',
    prices: {
      MarketId.migros: 72.9,
    },
  ),
  'sucuk-250__maret': MarketIndexEntry(
    product: 'Maret Altın Sucuk 250 Gr',
    unit: '250 GR',
    prices: {
      MarketId.carrefour: 563.9,
    },
  ),
  'sucuk-250__namet': MarketIndexEntry(
    product: 'Namet Dana Kasap Sucuk 250 Gr',
    unit: '250 GR',
    prices: {
      MarketId.migros: 299.0,
    },
  ),
  'sucuk-250__pinar': MarketIndexEntry(
    product: 'Pınar Gurme Sucuk 250 Gr',
    unit: '250 GR',
    prices: {
      MarketId.migros: 609.0,
      MarketId.carrefour: 479.9,
    },
  ),
  'sut-1l__dost': MarketIndexEntry(
    product: 'Dost %3.1 Yağlı Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.bim: 42.5,
    },
  ),
  'sut-1l__icim': MarketIndexEntry(
    product: 'İçim Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.migros: 69.5,
      MarketId.carrefour: 58.95,
    },
  ),
  'sut-1l__mis': MarketIndexEntry(
    product: 'Mis %3.1 Yağlı UHT Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.sok: 49.5,
    },
  ),
  'sut-1l__pinar': MarketIndexEntry(
    product: 'Pınar Yağlı Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.a101: 79.95,
      MarketId.carrefour: 69.95,
      MarketId.hakmar: 80.0,
    },
  ),
  'sut-1l__sek': MarketIndexEntry(
    product: 'Sek Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.migros: 68.95,
      MarketId.carrefour: 74.95,
    },
  ),
  'sut-1l__sutas': MarketIndexEntry(
    product: 'Sütaş %3,5 Tam Yağlı Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.carrefour: 69.95,
    },
  ),
  'sut-yarim-1l__icim': MarketIndexEntry(
    product: 'İçim Yarım Yağlı Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.migros: 59.75,
      MarketId.carrefour: 49.95,
      MarketId.hakmar: 57.5,
    },
  ),
  'sut-yarim-1l__mis': MarketIndexEntry(
    product: 'Mis Yarım Yağlı Uht Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.sok: 41.0,
    },
  ),
  'sut-yarim-1l__pinar': MarketIndexEntry(
    product: 'Pınar Yarım Yağlı Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.a101: 65.5,
    },
  ),
  'sut-yarim-1l__sek': MarketIndexEntry(
    product: 'Sek Yarım Yağlı Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.a101: 52.5,
      MarketId.carrefour: 64.95,
    },
  ),
  'sut-yarim-1l__sutas': MarketIndexEntry(
    product: 'Sütaş Yarım Yağlı Süt 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.carrefour: 67.25,
    },
  ),
  'tavuk-1kg__gedik': MarketIndexEntry(
    product: 'Gedik Piliç But Pirzola 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.sok: 249.0,
    },
  ),
  'tereyag-500__icim': MarketIndexEntry(
    product: 'İçim Tereyağı 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.migros: 478.95,
    },
  ),
  'tereyag-500__mis': MarketIndexEntry(
    product: 'Mis Tereyağı 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.sok: 279.0,
    },
  ),
  'ton-2x160__bizim-vatan': MarketIndexEntry(
    product: 'Bizim Vatan Ton Balığı 2x160 Gr',
    unit: '320 GR',
    prices: {
      MarketId.sok: 121.0,
    },
  ),
  'tuvalet-16__selpak': MarketIndexEntry(
    product: 'Selpak 3 Katlı Tuvalet Kağıdı 16 Adet',
    unit: null,
    prices: {
      MarketId.hakmar: 199.0,
    },
  ),
  'tuvalet-16__solo': MarketIndexEntry(
    product: 'Solo Bambu Katkılı Tuvalet Kağıdı 16 Adet',
    unit: null,
    prices: {
      MarketId.a101: 154.9,
    },
  ),
  'tuz-500__billur': MarketIndexEntry(
    product: 'Billur Tuz İyotlu Sofra Tuzu 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.a101: 54.5,
      MarketId.migros: 41.96,
      MarketId.carrefour: 27.0,
    },
  ),
  'un-5kg__piyale': MarketIndexEntry(
    product: 'Piyale Un 5 Kg',
    unit: '5 KG',
    prices: {
      MarketId.sok: 135.0,
    },
  ),
  'yogurt-1kg__eker': MarketIndexEntry(
    product: 'Eker Kaymaklı Tava Yoğurt 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.migros: 142.5,
      MarketId.carrefour: 119.95,
    },
  ),
  'yogurt-1kg__icim': MarketIndexEntry(
    product: 'İçim Doğal Yoğurt 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.carrefour: 89.95,
    },
  ),
  'yogurt-1kg__mis': MarketIndexEntry(
    product: 'Mis Kaymaklı Yoğurt 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.sok: 79.9,
    },
  ),
  'yogurt-1kg__sutas': MarketIndexEntry(
    product: 'Sütaş Kaymaksız Yoğurt 1 Kg',
    unit: '1 KG',
    prices: {
      MarketId.sok: 89.9,
      MarketId.carrefour: 101.95,
      MarketId.hakmar: 87.5,
      MarketId.tarimKredi: 79.5,
    },
  ),
  'yumurta-15__anadolu-ciftligi': MarketIndexEntry(
    product: 'Anadolu Çiftliği Yumurta 63-72 Gr 15 Adet',
    unit: null,
    prices: {
      MarketId.sok: 64.9,
    },
  ),
  'yumurta-30__anadolu-ciftligi': MarketIndexEntry(
    product: 'Anadolu Çiftliği Yumurta 53-62 Gr 30 Adet',
    unit: null,
    prices: {
      MarketId.sok: 129.0,
    },
  ),
  'zeytin-500__lio': MarketIndexEntry(
    product: 'Lio Salamura Siyah Zeytin 201-260 500 Gr',
    unit: '500 GR',
    prices: {
      MarketId.sok: 155.0,
    },
  ),
  'zeytinyagi-1l__komili': MarketIndexEntry(
    product: 'Komili Riviera Zeytinyağı 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.bim: 290.0,
      MarketId.carrefour: 399.95,
    },
  ),
  'zeytinyagi-1l__lio': MarketIndexEntry(
    product: 'Lio Sızma Zeytinyağı 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.sok: 310.0,
    },
  ),
  'zeytinyagi-1l__yudum': MarketIndexEntry(
    product: 'Yudum Egemden Riviera Zeytinyağı 1 Lt',
    unit: '1 LT',
    prices: {
      MarketId.a101: 299.0,
      MarketId.carrefour: 410.9,
    },
  ),
};
