/// Resmi market sitelerinden alınan referans birim fiyatlar.
///
/// Kaynaklar:
/// - https://www.sokmarket.com.tr (Şok Market e-ticaret API)
/// - https://happycenter.com.tr (Happy Center vitrin fiyatları)
///
/// Çekim: 2026-07-26. Demo/mock fiyat motorunun tabanı olarak kullanılır;
/// canlı modda backend teklifleri bunları geçersiz kılar.
class MarketPriceRef {
  const MarketPriceRef({
    required this.typeId,
    required this.unitPrice,
    required this.source,
    required this.sampleProduct,
  });

  final String typeId;
  final double unitPrice;
  final String source;
  final String sampleProduct;
}

const marketPriceSnapshotFetchedAt = '2026-07-26';

const marketPriceSnapshotSources = <String>[
  'https://www.sokmarket.com.tr',
  'https://happycenter.com.tr',
];

const marketPriceSnapshot = <String, MarketPriceRef>{
  'sut-1l': MarketPriceRef(
    typeId: 'sut-1l',
    unitPrice: 75.95,
    source: 'happycenter.com.tr',
    sampleProduct: 'İçim Süt Tam Yağlı Uht 1 lt',
  ),
  'sut-yarim-1l': MarketPriceRef(
    typeId: 'sut-yarim-1l',
    unitPrice: 65.0,
    source: 'happycenter.com.tr',
    sampleProduct: 'Sütaş Süt %2.5 Yağlı Uht 1 lt',
  ),
  'yumurta-30': MarketPriceRef(
    typeId: 'yumurta-30',
    unitPrice: 129.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Anadolu Çiftliği M Yumurta 30\'lu',
  ),
  'yumurta-15': MarketPriceRef(
    typeId: 'yumurta-15',
    unitPrice: 64.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Anadolu Çiftliği L Yumurta 15\'li',
  ),
  'peynir-500': MarketPriceRef(
    typeId: 'peynir-500',
    unitPrice: 139.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Mis Tam Yağlı Beyaz Peynir 500 g',
  ),
  'kasar-500': MarketPriceRef(
    typeId: 'kasar-500',
    unitPrice: 299.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Sütaş Kaşar Peyniri 500 g',
  ),
  'labne-400': MarketPriceRef(
    typeId: 'labne-400',
    unitPrice: 112.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Mis Labne Peyniri 400 g',
  ),
  'yogurt-1kg': MarketPriceRef(
    typeId: 'yogurt-1kg',
    unitPrice: 85.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'İçim Tam Yağlı Kaymaksız Yoğurt 1 Kg',
  ),
  'tereyag-500': MarketPriceRef(
    typeId: 'tereyag-500',
    unitPrice: 295.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Mis Tuzlu Tereyağı 500 g',
  ),
  'zeytin-500': MarketPriceRef(
    typeId: 'zeytin-500',
    unitPrice: 152.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Lio Salamura Siyah Zeytin',
  ),
  'recel-380': MarketPriceRef(
    typeId: 'recel-380',
    unitPrice: 89.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Reçel çeşitleri ortalama',
  ),
  'misir-gevregi': MarketPriceRef(
    typeId: 'misir-gevregi',
    unitPrice: 198.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Kellogg\'s Coco Pops 450 g',
  ),
  'ekmek-250': MarketPriceRef(
    typeId: 'ekmek-250',
    unitPrice: 49.95,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Tam Buğday Unlu Ekmek',
  ),
  'ekmek-beyaz': MarketPriceRef(
    typeId: 'ekmek-beyaz',
    unitPrice: 17.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Odun Ekmek',
  ),
  'pirinc-1kg': MarketPriceRef(
    typeId: 'pirinc-1kg',
    unitPrice: 66.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Anadolu Mutfağı Yasemin Pirinç 1 kg',
  ),
  'makarna-500': MarketPriceRef(
    typeId: 'makarna-500',
    unitPrice: 33.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Nuh\'un Ankara Spaghetti 500 g',
  ),
  'makarna-penne': MarketPriceRef(
    typeId: 'makarna-penne',
    unitPrice: 47.95,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Barilla Penne Rigate 500 g',
  ),
  'aycicek-1l': MarketPriceRef(
    typeId: 'aycicek-1l',
    unitPrice: 122.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Evin Ayçiçek Yağı 1 L',
  ),
  'aycicek-5l': MarketPriceRef(
    typeId: 'aycicek-5l',
    unitPrice: 469.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Evin Ayçiçek Yağı Pet 5 L',
  ),
  'zeytinyagi-1l': MarketPriceRef(
    typeId: 'zeytinyagi-1l',
    unitPrice: 310.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Lio Sızma Zeytinyağı 1 L',
  ),
  'seker-2kg': MarketPriceRef(
    typeId: 'seker-2kg',
    unitPrice: 94.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Altınküp Toz Şeker 2000 g',
  ),
  'seker-1kg': MarketPriceRef(
    typeId: 'seker-1kg',
    unitPrice: 47.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Altınküp Toz Şeker 2000 g birim fiyatı',
  ),
  'un-5kg': MarketPriceRef(
    typeId: 'un-5kg',
    unitPrice: 135.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Piyale Un 5 Kg',
  ),
  'tuz-750': MarketPriceRef(
    typeId: 'tuz-750',
    unitPrice: 54.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Billur Tuz Rafine İyotlu',
  ),
  'mercimek-1kg': MarketPriceRef(
    typeId: 'mercimek-1kg',
    unitPrice: 49.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Anadolu Mutfağı Kırmızı Mercimek 1 kg',
  ),
  'nohut-1kg': MarketPriceRef(
    typeId: 'nohut-1kg',
    unitPrice: 62.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Anadolu Mutfağı Nohut 1 kg',
  ),
  'bulgur-1kg': MarketPriceRef(
    typeId: 'bulgur-1kg',
    unitPrice: 35.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Anadolu Mutfağı Esmer Köftelik Bulgur 1 kg',
  ),
  'salca-700': MarketPriceRef(
    typeId: 'salca-700',
    unitPrice: 72.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Acı Biber Salçası Bizim Vatan 650 g',
  ),
  'ketcap-600': MarketPriceRef(
    typeId: 'ketcap-600',
    unitPrice: 79.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Ketçap Bizim Vatan',
  ),
  'mayonez-550': MarketPriceRef(
    typeId: 'mayonez-550',
    unitPrice: 140.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Mayonez Bizim Vatan',
  ),
  'ton-160': MarketPriceRef(
    typeId: 'ton-160',
    unitPrice: 60.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Ton Balığı Bizim Vatan',
  ),
  'konserve-fasulye': MarketPriceRef(
    typeId: 'konserve-fasulye',
    unitPrice: 40.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Haşlanmış Kuru Fasulye Bizim Vatan 800 g',
  ),
  'konserve-misir': MarketPriceRef(
    typeId: 'konserve-misir',
    unitPrice: 89.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Superfresh Mısır Konservesi',
  ),
  'cay-500': MarketPriceRef(
    typeId: 'cay-500',
    unitPrice: 209.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Çaykur Çay Çiçeği 500 g',
  ),
  'cay-1000': MarketPriceRef(
    typeId: 'cay-1000',
    unitPrice: 299.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Lipton Yellow Label Çay 1000 g',
  ),
  'su-5l': MarketPriceRef(
    typeId: 'su-5l',
    unitPrice: 57.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Saka Su 5 L',
  ),
  'su-1-5l': MarketPriceRef(
    typeId: 'su-1-5l',
    unitPrice: 34.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Saka Su 1.5 L',
  ),
  'su-6x': MarketPriceRef(
    typeId: 'su-6x',
    unitPrice: 209.4,
    source: 'sokmarket.com.tr',
    sampleProduct: '6 x Saka Su 1.5 L',
  ),
  'kola-1l': MarketPriceRef(
    typeId: 'kola-1l',
    unitPrice: 60.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Coca-Cola 1 L',
  ),
  'kola-2-5l': MarketPriceRef(
    typeId: 'kola-2-5l',
    unitPrice: 59.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Cola Turka 2,5 L',
  ),
  'ayran-285': MarketPriceRef(
    typeId: 'ayran-285',
    unitPrice: 13.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Mis Ayran Tam Yağlı 285 ml',
  ),
  'kahve-100': MarketPriceRef(
    typeId: 'kahve-100',
    unitPrice: 89.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Karaca Hatır Türk Kahvesi 100 g',
  ),
  'filtre-kahve': MarketPriceRef(
    typeId: 'filtre-kahve',
    unitPrice: 275.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Mehmet Efendi Colombian Filtre Kahve 250 g',
  ),
  'meyvesuyu-1l': MarketPriceRef(
    typeId: 'meyvesuyu-1l',
    unitPrice: 69.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Meysu %100 Karışık Meyve Suyu 1 L',
  ),
  'maden-6x': MarketPriceRef(
    typeId: 'maden-6x',
    unitPrice: 66.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Beypazarı Maden Suyu 6*200 mL',
  ),
  'domates-1kg': MarketPriceRef(
    typeId: 'domates-1kg',
    unitPrice: 43.75,
    source: 'happycenter.com.tr',
    sampleProduct: 'Domates',
  ),
  'patates-1kg': MarketPriceRef(
    typeId: 'patates-1kg',
    unitPrice: 39.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Patates Kg',
  ),
  'muz-1kg': MarketPriceRef(
    typeId: 'muz-1kg',
    unitPrice: 94.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Yerli Muz Kg',
  ),
  'sogan-1kg': MarketPriceRef(
    typeId: 'sogan-1kg',
    unitPrice: 54.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Kuru Soğan Kg',
  ),
  'salatalik-1kg': MarketPriceRef(
    typeId: 'salatalik-1kg',
    unitPrice: 49.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Salatalık Kg',
  ),
  'havuc-1kg': MarketPriceRef(
    typeId: 'havuc-1kg',
    unitPrice: 34.35,
    source: 'happycenter.com.tr',
    sampleProduct: 'Havuç',
  ),
  'biber-1kg': MarketPriceRef(
    typeId: 'biber-1kg',
    unitPrice: 139.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Çarliston Biber Kg',
  ),
  'patlican-1kg': MarketPriceRef(
    typeId: 'patlican-1kg',
    unitPrice: 59.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Patlıcan Kemer Kg',
  ),
  'kabak-1kg': MarketPriceRef(
    typeId: 'kabak-1kg',
    unitPrice: 69.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Kabak Sakız Kg',
  ),
  'fasulye-1kg': MarketPriceRef(
    typeId: 'fasulye-1kg',
    unitPrice: 99.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Fasulye Ayşe Kadın Kg',
  ),
  'sarimsak-250': MarketPriceRef(
    typeId: 'sarimsak-250',
    unitPrice: 59.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Sarımsak 250 Gr',
  ),
  'maydanoz': MarketPriceRef(
    typeId: 'maydanoz',
    unitPrice: 15.65,
    source: 'happycenter.com.tr',
    sampleProduct: 'Maydanoz',
  ),
  'pilic-butun': MarketPriceRef(
    typeId: 'pilic-butun',
    unitPrice: 94.9,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Gedik Bütün Piliç Kg',
  ),
  'pilic-but': MarketPriceRef(
    typeId: 'pilic-but',
    unitPrice: 125.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Gedik Piliç Kalçalı But Kg',
  ),
  'tavuk-1kg': MarketPriceRef(
    typeId: 'tavuk-1kg',
    unitPrice: 249.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Gedik Piliç But Pirzola Kg',
  ),
  'kofte-400': MarketPriceRef(
    typeId: 'kofte-400',
    unitPrice: 231.2,
    source: 'sokmarket.com.tr',
    sampleProduct: 'İnci Dana Kuzu Kaşarlı Köfte ölçekli',
  ),
  'sucuk-250': MarketPriceRef(
    typeId: 'sucuk-250',
    unitPrice: 189.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Sultan Kangal Sucuk 250 g',
  ),
  'salam-200': MarketPriceRef(
    typeId: 'salam-200',
    unitPrice: 188.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Namet Dana Macar Salam ölçekli',
  ),
  'sosis-190': MarketPriceRef(
    typeId: 'sosis-190',
    unitPrice: 135.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Aytaç Dana Sosis 190 g',
  ),
  'kiyma-400': MarketPriceRef(
    typeId: 'kiyma-400',
    unitPrice: 330.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Lezzetlim Dana Kıyma 400 g',
  ),
  'deterjan-3kg': MarketPriceRef(
    typeId: 'deterjan-3kg',
    unitPrice: 235.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Omo Matik Color Toz Deterjan',
  ),
  'bulasik-750': MarketPriceRef(
    typeId: 'bulasik-750',
    unitPrice: 199.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Bingo Elde Bulaşık Deterjanı',
  ),
  'yumusatici-2l': MarketPriceRef(
    typeId: 'yumusatici-2l',
    unitPrice: 149.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Peros Konsantre Yumuşatıcı',
  ),
  'tuvalet-16': MarketPriceRef(
    typeId: 'tuvalet-16',
    unitPrice: 169.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Beyaz Güvercin Tuvalet Kağıdı 16\'lı',
  ),
  'tuvalet-8': MarketPriceRef(
    typeId: 'tuvalet-8',
    unitPrice: 99.0,
    source: 'sokmarket.com.tr',
    sampleProduct: '16\'lı paket fiyatından ölçekli',
  ),
  'cop-torbasi': MarketPriceRef(
    typeId: 'cop-torbasi',
    unitPrice: 75.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Saroz Büzgülü Çöp Torbası',
  ),
  'sampuan-400': MarketPriceRef(
    typeId: 'sampuan-400',
    unitPrice: 149.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Elidor Işıltı Serisi Şampuan 400 Ml',
  ),
  'dis-macunu': MarketPriceRef(
    typeId: 'dis-macunu',
    unitPrice: 147.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Colgate Max White Purple 75 Ml',
  ),
  'sabun-4': MarketPriceRef(
    typeId: 'sabun-4',
    unitPrice: 149.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Duru Türk Hamamı Klasik Sabun 4*200 G',
  ),
  'dus-jeli': MarketPriceRef(
    typeId: 'dus-jeli',
    unitPrice: 299.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Le Petit Marseillais Duş Jeli',
  ),
  'cips-107': MarketPriceRef(
    typeId: 'cips-107',
    unitPrice: 62.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Amigo / Lays tipi cips ortalama',
  ),
  'biskuvi': MarketPriceRef(
    typeId: 'biskuvi',
    unitPrice: 65.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Bisküvi çeşitleri ortalama',
  ),
  'cikolata': MarketPriceRef(
    typeId: 'cikolata',
    unitPrice: 65.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Sütlü çikolata ortalama',
  ),
  'gofret': MarketPriceRef(
    typeId: 'gofret',
    unitPrice: 49.95,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Gofret çeşitleri ortalama',
  ),
  'kek': MarketPriceRef(
    typeId: 'kek',
    unitPrice: 49.95,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Kek çeşitleri ortalama',
  ),
  'kraker': MarketPriceRef(
    typeId: 'kraker',
    unitPrice: 22.5,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Ülker Çiziviç Kraker',
  ),
  'findik-ici': MarketPriceRef(
    typeId: 'findik-ici',
    unitPrice: 188.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Amigo Fındık İçi 150 g',
  ),
  'dondurma-500': MarketPriceRef(
    typeId: 'dondurma-500',
    unitPrice: 200.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Algida Maraş Usulü Sade 500 ml',
  ),
  'bebek-bezi': MarketPriceRef(
    typeId: 'bebek-bezi',
    unitPrice: 199.0,
    source: 'sokmarket.com.tr',
    sampleProduct: 'Bebeland / Sleepy bebek bezi',
  ),
};
