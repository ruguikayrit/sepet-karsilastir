/// Marka + birim düzeyinde doğrulanmış market ürün kayıtları.
///
/// Anahtar, [ProductType.withBrand] ile üretilen ürün kimliğidir
/// (`<tipId>__<markaAnahtarı>`). Yalnızca marka VE birim birebir eşleşen
/// ürünler buraya girer; bu yüzden bir satırın bağlantısı her zaman aynı
/// markanın aynı gramajına gider.
///
/// Kaynaklar: sokmarket.com.tr ürün sayfaları, happycenter.com.tr ürün
/// arama servisi. Çekim: 2026-07-26.
library;

class MarketProductRef {
  const MarketProductRef({
    required this.name,
    required this.path,
    required this.price,
    this.inStock = true,
  });

  /// Marketin sitesindeki tam ürün adı.
  final String name;

  /// Market alan adına göreli ürün yolu.
  final String path;

  /// Çekim anındaki satış fiyatı (TRY).
  final double price;

  /// Çekim anında online stokta mıydı?
  final bool inStock;
}

class MarketProductEntry {
  const MarketProductEntry({this.sok, this.happyCenter});

  final MarketProductRef? sok;
  final MarketProductRef? happyCenter;

  Iterable<MarketProductRef> get all => [
        if (sok != null) sok!,
        if (happyCenter != null) happyCenter!,
      ];
}

const marketProductSnapshotFetchedAt = '2026-07-26';

const marketProductSnapshot = <String, MarketProductEntry>{
  'aycicek-1l__evin': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Evin Ayçiçek Yağı 1 L',
      path: 'evin-aycicek-yagi-1-l-p-8747',
      price: 122.0,
    ),
  ),
  'aycicek-1l__komili': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Komili Ayçiçek Yağı 1 lt',
      path: 'Komili_Y_aycicek_Yagi_1_Lt',
      price: 155.3,
    ),
  ),
  'aycicek-1l__yudum': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Yudum Ayçiçek Yağı 1 lt',
      path: 'Yudum_Y_aycicek_Yagi_1_Lt',
      price: 188.6,
    ),
  ),
  'aycicek-5l__evin': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Evin Ayçiçek Yağı Pet 5 L',
      path: 'evin-aycicek-yagi-pet-5-l-p-6486',
      price: 469.0,
    ),
  ),
  'aycicek-5l__komili': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Komili Ayçiçek Yağı  Kare Kubbeli Pet 5 lt.',
      path: 'komili-aycicek-yagi--kare-kubbeli-pet-5-lt-',
      price: 577.1,
    ),
  ),
  'aycicek-5l__yudum': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Yudum Ayçiçek Yağı  Pet 5 Lt',
      path: 'Yudum_Aycicek_Yagi_5_Lt_Pet',
      price: 588.2,
    ),
  ),
  'ayran-285__mis': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mis Ayran Tam Yağlı 285 ml',
      path: 'mis-ayran-tam-yagli-285-ml-p-6643',
      price: 13.5,
    ),
  ),
  'bebek-bezi__bebeland': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Bebeland Kanallı Maxi Bebek Bezi 40 Adet',
      path: 'bebeland-kanalli-maxi-bebek-bezi-40-adet-p-267697',
      price: 199.0,
    ),
  ),
  'bebek-bezi__sleepy': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Sleepy Natural Double Soft Bebek Bezi Xl 40\'lı',
      path: 'sleepy-natural-double-soft-bebek-bezi-xl-40-li-p-690890',
      price: 265.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Sleepy Çocuk Bezi Nat Klt 2 Li XL 40 Lı',
      path: 'sleepy-cocuk-bezi-nat-klt-2-li-xl-40-li',
      price: 188.7,
    ),
  ),
  'bulasik-1500__bingo': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Bingo Elde Bulaşık Deterjanı Limon 1500 Ml',
      path: 'bingo-elde-bulasik-deterjani-limon-1500-ml-p-479491',
      price: 199.0,
    ),
  ),
  'bulgur-1kg__anadolu-mutfagi': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Anadolu Mutfağı Köftelik Bulgur 1 kg',
      path: 'anadolu-mutfagi-koftelik-bulgur-1-kg-p-7644',
      price: 34.0,
    ),
  ),
  'bulgur-1kg__reis': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Reis Konya Köftelik Bulgur 1 kg',
      path: 'Reis_1000_Gr_Bulgur_Koftelik_Konya',
      price: 77.6,
    ),
  ),
  'cay-1000__caykur': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Çaykur Rize Turist Çay 1000 g',
      path: 'caykur-rize-turist-cay-1000-g-p-7545',
      price: 365.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Çaykur Tiryaki 1000 gr',
      path: 'Caykur_1000_Gr_Cay_Tiryaki',
      price: 420.6,
    ),
  ),
  'cay-1000__dogus': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Doğuş Çay Siyah 1 kg',
      path: 'dogus-cay-siyah-1-kg-p-5134',
      price: 325.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Doğuş Sarı Rize Çay 1000 gr',
      path: 'Dogus_1000_Gr_Cay_Rize_Sari',
      price: 344.0,
    ),
  ),
  'cay-1000__lipton': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Lipton Yellow Label Çay 1000 g',
      path: 'lipton-yellow-label-cay-1000-g-p-5132',
      price: 299.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Lipton Dökme Çay Doğu Karadeniz 1000 gr',
      path: 'Lipton_1000_Gr_Cay_Siyah_D_karadeniz',
      price: 366.2,
    ),
  ),
  'cay-500__caykur': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Çaykur Filiz Çay 500 g',
      path: 'caykur-filiz-cay-500-g-p-4576',
      price: 225.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Çaykur Kamelya Çay 500 gr',
      path: 'Caykur_500_Gr_Cay_Kamelya',
      price: 210.8,
    ),
  ),
  'cay-500__dogus': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Doğuş Rize Harman Çay 500 gr',
      path: 'Dogus_500_Gr_Cay_Rize_Extra_Harman',
      price: 188.6,
    ),
  ),
  'cay-500__lipton': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Lipton Yellow Label Çay 500 g',
      path: 'lipton-yellow-label-cay-500-g-p-48654',
      price: 159.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Lipton Yellow Label Dökme Çay Pouch 500 gr',
      path: 'Lipton_500_Gr_Cay_Yellow_Label_Pouch_',
      price: 199.7,
    ),
  ),
  'cikolata-100__eti': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Eti Sütlü Çikolata 100 g',
      path: 'eti-sutlu-cikolata-100-g-p-1984',
      price: 50.0,
      inStock: false,
    ),
  ),
  'cikolata-100__ulker': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Ülker Laviva Mid Size Sütlü Çikolata 100 g',
      path: 'ulker-laviva-mid-size-sutlu-cikolata-100-g-p-730267',
      price: 89.95,
      inStock: false,
    ),
  ),
  'cips-150__amigo': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Amigo Düz Sade Patates Cipsi 150 g',
      path: 'amigo-duz-sade-patates-cipsi-150-g-p-4767',
      price: 46.5,
    ),
  ),
  'deterjan-1-5kg__ariel': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Ariel Toz Çamaşır Deterjanı Dağ Esintisi 1,5 kg',
      path: 'Ariel_Matik_1_5_Kg_Dag_Esintisi',
      price: 199.7,
    ),
  ),
  'deterjan-1-5kg__bingo': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Bingo Matik Çamaşır Deterjanı Renkli 1,5 kg',
      path: 'Bingo_Matik_1500_Gr_lovely_Parfumlu',
      price: 166.4,
    ),
  ),
  'deterjan-1-5kg__omo': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Omo Matik Color Toz Deterjan 1.5 Kg',
      path: 'omo-matik-color-toz-deterjan-1-5-kg-p-5366',
      price: 235.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Omo Matik Active Fresh Toz Çamaşır Deterjanı 1,5 kg',
      path: 'Omo_Matik_1500_Gr_Active_Fresh',
      price: 177.5,
    ),
  ),
  'deterjan-1-5kg__persil': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Persil Expert Çamaşır Deterjanı Gül Büyüsü 1,5 kg',
      path: 'Persil_Gold_1500_Gr_Gulun_Buyusu',
      price: 221.9,
    ),
  ),
  'dis-macunu__colgate': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Colgate Üçlü Etki Diş Macunu 75 ml',
      path: 'colgate-uclu-etki-dis-macunu-75-ml-p-3949',
      price: 99.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Colgate Diş Macunu Üçlü Etki 75 Ml',
      path: 'colgate-dis-macunu-uclu-etki-75-ml',
      price: 99.75,
    ),
  ),
  'dondurma-500__algida': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Algida Maraş Usulü Sade Dondurma 500 ml',
      path: 'algida-maras-usulu-sade-dondurma-500-ml-p-8891',
      price: 200.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Algida Dond Inh. Almido Dondurma 500 Ml',
      path: 'algida-dond-inh--almido-dondurma-500-ml',
      price: 150.0,
    ),
  ),
  'dus-jeli__dove': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Dove Original Duş Jeli 500 Ml',
      path: 'dove-original-dus-jeli-500-ml-p-41647',
      price: 101.65,
      inStock: false,
    ),
  ),
  'dus-jeli__duru': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Duru Değerli Yağlar Duş Jeli 500 Ml',
      path: 'duru-degerli-yaglar-dus-jeli-500-ml-p-3968',
      price: 14.25,
      inStock: false,
    ),
  ),
  'filtre-kahve__mehmet-efendi': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mehmet Efendi Colombian Filtre Kahve 250 g',
      path: 'mehmet-efendi-colombian-filtre-kahve-250-g-p-3601',
      price: 275.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Mehmet Efendi Filtre Kahve Brazilian 250 Gr',
      path: 'mehmet-efendi-filtre-kahve-brazilian-',
      price: 277.35,
    ),
  ),
  'findik-ici__amigo': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Amigo Fındık İçi 150 g',
      path: 'amigo-findik-ici-150-g-p-8465',
      price: 188.0,
    ),
  ),
  'kahve-100__mehmet-efendi': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Kurukahveci Mehmet Efendi Türk Kahvesi 100 g',
      path: 'kurukahveci-mehmet-efendi-turk-kahvesi-100-g-p-4743',
      price: 97.5,
    ),
    happyCenter: MarketProductRef(
      name: 'Mehmet Efendi Türk Kahvesi 100 Gr',
      path: 'Mehmet_Efendi_100_Gr_Turk_Kahvesi',
      price: 108.2,
    ),
  ),
  'kasar-500__mis': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mis Tam Yağlı Kaşar Peyniri 500 g',
      path: 'mis-tam-yagli-kasar-peyniri-500-g-p-8768',
      price: 227.0,
    ),
  ),
  'kasar-500__muratbey': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Muratbey Tam Yağlı Taze Kaşar Peynir 500 g',
      path: 'muratbey-tam-yagli-taze-kasar-peynir-500-g-p-640061',
      price: 219.0,
      inStock: false,
    ),
    happyCenter: MarketProductRef(
      name: 'Muratbey Taze Kaşar Peyniri 500 Gr',
      path: 'Muratbey_Taze_Kasar_400_Gr',
      price: 360.65,
    ),
  ),
  'kasar-500__sutas': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Sütaş Kaşar Peyniri 500 g',
      path: 'sutas-kasar-peyniri-500-g-p-4684',
      price: 299.0,
    ),
  ),
  'kek-162__solen': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Şölen Luppo Vişneli Brownie Kek 162 g',
      path: 'solen-luppo-visneli-brownie-kek-162-g-p-766029',
      price: 49.95,
    ),
  ),
  'kek-162__ulker': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Ülker 8 Kek Orman Meyveli 162 g',
      path: 'ulker-8-kek-orman-meyveli-162-g-p-489910',
      price: 49.95,
    ),
    happyCenter: MarketProductRef(
      name: 'Ülker 8 Kek Mini Muzlu Kek 162 Gr',
      path: 'ulker-8-kek-mini-muzlu-kek-162-gr',
      price: 48.8,
    ),
  ),
  'ketcap-500__bizim-vatan': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Ketçap Bizim Vatan 500 g',
      path: 'ketcap-bizim-vatan-500-g-p-8444',
      price: 39.9,
    ),
  ),
  'kiyma-400__lezzetlim': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Lezzetlim Dana Kıyma 400 g',
      path: 'lezzetlim-dana-kiyma-400-g-p-5443',
      price: 330.0,
    ),
  ),
  'kofte-500__aytac': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Aytaç Dondurulmuş Dana Maydanozlu Köfte 500 g',
      path: 'aytac-dondurulmus-dana-maydanozlu-kofte-500-g-p-636121',
      price: 399.0,
    ),
  ),
  'kola-1l__coca-cola': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Coca-Cola 1 L',
      path: 'coca-cola-1-l-p-4687',
      price: 60.0,
    ),
  ),
  'kola-2-5l__coca-cola': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Coca-Cola 2.5 L',
      path: 'coca-cola-2-5-l-p-4797',
      price: 90.0,
    ),
  ),
  'kola-2-5l__cola-turka': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Cola Turka 2,5 L',
      path: 'cola-turka-2-5-l-p-5546',
      price: 59.9,
    ),
  ),
  'konserve-fasulye__bizim-vatan': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Haşlanmış Kuru Fasulye Bizim Vatan 800 g',
      path: 'haslanmis-kuru-fasulye-bizim-vatan-800-g-p-5612',
      price: 40.5,
    ),
  ),
  'konserve-misir__bizim-vatan': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mısır Konservesi 3*200 G Bizim Vatan',
      path: 'misir-konservesi-3-200-g-bizim-vatan-p-725148',
      price: 62.9,
      inStock: false,
    ),
  ),
  'konserve-misir__superfresh': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Superfresh Mısır Konservesi 3*200 g',
      path: 'superfresh-misir-konservesi-3-200-g-p-5279',
      price: 89.0,
    ),
  ),
  'kraker-82__ulker': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Ülker Çiziviç Kraker Peynirli Sandviç 82 g',
      path: 'ulker-cizivic-kraker-peynirli-sandvic-82-g-p-7091',
      price: 22.5,
    ),
    happyCenter: MarketProductRef(
      name: 'Ülker B.Çiziviç Haşhaşlı Baharatlı Kraker 82 Gr',
      path: 'ulker-b-cizivic-hashasli-baharatli-kraker-82-gr',
      price: 18.3,
    ),
  ),
  'labne-400__icim': MarketProductEntry(
    sok: MarketProductRef(
      name: 'İçim Labne Peyniri 400 g',
      path: 'icim-labne-peyniri-400-g-p-8449',
      price: 149.0,
    ),
    happyCenter: MarketProductRef(
      name: 'İçim Labne 400 gr',
      path: 'Icim_Labne_500_Gr',
      price: 183.05,
    ),
  ),
  'labne-400__mis': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mis Labne Peyniri 400 g',
      path: 'mis-labne-peyniri-400-g-p-5592',
      price: 112.0,
    ),
  ),
  'labne-400__pinar': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Pınar Labne Peynir 400 gr',
      path: 'Pinar_Labne_400_Gr',
      price: 149.75,
    ),
  ),
  'labne-400__sutas': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Sütaş Labne Peynir 400 gr',
      path: 'Sutas_Labne_Peynir_400_Gr',
      price: 177.5,
    ),
  ),
  'maden-6x__beypazari': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Beypazarı Maden Suyu 6*200 mL',
      path: 'beypazari-maden-suyu-6-200-ml-p-5812',
      price: 66.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Beypazarı Maden Suyu 6x 200 Ml',
      path: 'r-beypazari-maden-suyu-6x200-ml',
      price: 77.6,
    ),
  ),
  'maden-6x__saka': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Saka Maden Suyu 6X200 Ml.',
      path: 'saka-6-x-200-ml-maden-suyu',
      price: 63.2,
    ),
  ),
  'maden-6x__uludag': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'ULUDAG 6X200 ML MADEN SUYU SADE CAM',
      path: 'Uludag_6_X_200_Ml_Maden_Suyu_Cam',
      price: 77.6,
    ),
  ),
  'makarna-500__ankara': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Nuhun Ankara Spaghetti Makarna 500 gr',
      path: 'D_ankara_500_Gr_Spagetti_Makarna',
      price: 37.65,
    ),
  ),
  'makarna-500__barilla': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Barilla Spagetti Makarna No:5 500 g',
      path: 'barilla-spagetti-makarna-no-5-500-g-p-8013',
      price: 47.95,
    ),
    happyCenter: MarketProductRef(
      name: 'Barilla Makarna Spagetti 500 gr',
      path: 'Barilla_500_Gr_Makarna_Spagetti',
      price: 66.5,
    ),
  ),
  'makarna-500__filiz': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Filiz Makarna Spaghetti 500 g',
      path: 'filiz-makarna-spaghetti-500-g-p-4845',
      price: 33.5,
    ),
    happyCenter: MarketProductRef(
      name: 'Filiz Spagetti Makarna 500 gr',
      path: 'Filiz_500_Gr_Makarna_Spagetti',
      price: 37.65,
    ),
  ),
  'makarna-500__nuh-un-ankara': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Nuh\'un Ankara Vitaminli Spaghetti 500 g',
      path: 'nuh-un-ankara-vitaminli-spaghetti-500-g-p-8012',
      price: 33.5,
    ),
  ),
  'makarna-500__pastavilla': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Pastavilla Spagetti Makarna 500 g',
      path: 'pastavilla-spagetti-makarna-500-g-p-98730',
      price: 27.9,
      inStock: false,
    ),
    happyCenter: MarketProductRef(
      name: 'Pastavilla Spaghetti Makarna 500 gr',
      path: 'Pastavilla_500_Gr_Spaghetti_Makarna',
      price: 33.2,
    ),
  ),
  'makarna-500__piyale': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Piyale Spagetti 500 g',
      path: 'piyale-spagetti-500-g-p-5641',
      price: 17.0,
    ),
  ),
  'makarna-penne__ankara': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Nuhun Ankara Penne Makarna 500 gr',
      path: 'Ankara_500_Gr_Penne_Makarna',
      price: 37.65,
    ),
  ),
  'makarna-penne__barilla': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Barilla Penne Rigate (Kalem) Makarna 500 g',
      path: 'barilla-penne-rigate-kalem-makarna-500-g-p-4733',
      price: 47.95,
    ),
    happyCenter: MarketProductRef(
      name: 'Barilla Penne Rigate Kalem Makarna 500 gr',
      path: 'Barilla_500_Gr_Makarna_Kalem_penne_Rigate',
      price: 66.5,
    ),
  ),
  'makarna-penne__filiz': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Filiz Kalem Makarna 500 gr',
      path: 'Filiz_500_Gr_Makarna_Kisa_Kalem',
      price: 37.65,
    ),
  ),
  'makarna-penne__pastavilla': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Pastavilla Kalem Makarna 500 g',
      path: 'pastavilla-kalem-makarna-500-g-p-97282',
      price: 27.9,
      inStock: false,
    ),
    happyCenter: MarketProductRef(
      name: 'Pastavilla Kalem Makarna 500 gr',
      path: 'Pastavilla_500_Gr_Kalem_Makarna',
      price: 33.2,
    ),
  ),
  'mayonez-430__bizim-vatan': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mayonez Bizim Vatan 430 g',
      path: 'mayonez-bizim-vatan-430-g-p-8372',
      price: 79.0,
    ),
  ),
  'mercimek-1kg__anadolu-mutfagi': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Anadolu Mutfağı Kırmızı Mercimek 1000 g',
      path: 'anadolu-mutfagi-kirmizi-mercimek-1000-g-p-9055',
      price: 49.5,
    ),
  ),
  'meyvesuyu-1l__meysu': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Meysu % 100 Karışık Meyve Suyu 1 L',
      path: 'meysu-100-karisik-meyve-suyu-1-l-p-138',
      price: 69.9,
    ),
  ),
  'meyvesuyu-1l__mis': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mis Meyve Nektarı Vişne 1 L',
      path: 'mis-meyve-nektari-visne-1-l-p-8627',
      price: 62.5,
    ),
  ),
  'misir-gevregi__kellogg-s': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Kellogg\'s Coco Pops Kakaolu Mısır ve Buğday Gevreği 450 g',
      path: 'kellogg-s-coco-pops-kakaolu-misir-ve-bugday-gevregi-450-g-p-8899',
      price: 198.5,
    ),
  ),
  'nohut-1kg__anadolu-mutfagi': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Anadolu Mutfağı Nohut 1 kg',
      path: 'anadolu-mutfagi-nohut-1-kg-p-9054',
      price: 62.5,
    ),
  ),
  'nohut-1kg__reis': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Reis Nevşehir Nohut 1 kg',
      path: 'Reis_1000_Gr_Nohut_Nevsehir_',
      price: 244.1,
    ),
  ),
  'peynir-500__icim': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'İçim  Beyaz Peynir Tam Yağlı 500 gr',
      path: 'Icim_Tam_Yagli_Beyaz_Peynir_500_Gr',
      price: 210.8,
    ),
  ),
  'peynir-500__mis': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mis Tam Yağlı Beyaz Peynir 500 g',
      path: 'mis-tam-yagli-beyaz-peynir-500-g-p-7382',
      price: 139.0,
    ),
  ),
  'peynir-500__sutas': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Sütaş Tam Yağlı Beyaz Peynir 500 g',
      path: 'sutas-tam-yagli-beyaz-peynir-500-g-p-8473',
      price: 142.0,
      inStock: false,
    ),
    happyCenter: MarketProductRef(
      name: 'Sütaş Beyaz Peynir Tam Yağlı 500 gr',
      path: 'Sutas_Tam_Yagli_Beyaz_Peynir_500_Gr',
      price: 199.7,
    ),
  ),
  'peynir-500__tahsildaroglu': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Tahsildaroğlu Beyaz Peynir Klasik 500 gr',
      path: 'tahsildaroglu-beyaz-peynir-ezine-klasik-500-gr',
      price: 366.2,
    ),
  ),
  'pilic-but__gedik': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Gedik Piliç Kalçalı But Kg',
      path: 'gedik-pilic-kalcali-but-kg-p-460899',
      price: 125.0,
    ),
  ),
  'pilic-butun__gedik': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Gedik Bütün Piliç Kg',
      path: 'gedik-butun-pilic-kg-p-440564',
      price: 94.9,
    ),
  ),
  'pilic-butun__senpilic': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Şenpiliç Bütün Piliç kg',
      path: 'senpilic-butun-pilic-kg-p-6409',
      price: 94.9,
      inStock: false,
    ),
  ),
  'pirinc-1kg__anadolu-mutfagi': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Anadolu Mutfağı Kırık Pirinç 1 kg',
      path: 'anadolu-mutfagi-kirik-pirinc-1-kg-p-5789',
      price: 32.5,
    ),
  ),
  'pirinc-1kg__reis': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Reis Kesme Kırık Pirinç 1 kg',
      path: 'Reis_1000_Gr_Pirinc_Kesme_Kirik',
      price: 66.5,
    ),
  ),
  'sabun-4__duru': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Duru Türk Hamamı Klasik Sabun 4*200 G',
      path: 'duru-turk-hamami-klasik-sabun-4-200-g-p-489911',
      price: 149.0,
    ),
  ),
  'salam-60__aytac': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Aytaç Şipşak Dana Salam Dilimli 60 g',
      path: 'aytac-sipsak-dana-salam-dilimli-60-g-p-7045',
      price: 42.5,
    ),
  ),
  'salam-60__banvit': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Banvit Bi Dilim Piliç Salam 60 g',
      path: 'banvit-bi-dilim-pilic-salam-60-g-p-6935',
      price: 22.0,
      inStock: false,
    ),
  ),
  'salam-60__maret': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Maret Enfes Dana Macar Salam 60 g',
      path: 'maret-enfes-dana-macar-salam-60-g-p-2341',
      price: 42.5,
      inStock: false,
    ),
    happyCenter: MarketProductRef(
      name: 'Maret Hindi Salam Pratik 60gr',
      path: 'Maret_Pratik_Hindi_Salam_60_Gr',
      price: 41.0,
    ),
  ),
  'salam-60__namet': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Namet Dana Macar Salam 60 g',
      path: 'namet-dana-macar-salam-60-g-p-6063',
      price: 56.5,
    ),
    happyCenter: MarketProductRef(
      name: 'Namet 7/24 Hindi Salam 60 Gr',
      path: 'd-namet-hindi-salam-60-gr',
      price: 38.75,
    ),
  ),
  'salam-60__sultan': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Sultan Dana Macar Salam 60 g',
      path: 'sultan-dana-macar-salam-60-g-p-7415',
      price: 42.5,
      inStock: false,
    ),
  ),
  'salca-650__bizim-vatan': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Tatlı Biber Salçası Bizim Vatan 650 g',
      path: 'tatli-biber-salcasi-bizim-vatan-650-g-p-8365',
      price: 72.5,
    ),
  ),
  'sampuan-400__dove': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Dove Yoğun Onarıcı Şampuan 400 ml',
      path: 'dove-yogun-onarici-sampuan-400-ml-p-47251',
      price: 139.0,
      inStock: false,
    ),
  ),
  'sampuan-400__duru': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Duru Şampuan Kepeğe Karşı 400 Ml',
      path: 'duru-sampuan-kepege-karsi-400-ml-p-691130',
      price: 99.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Duru Şampuan Nem Bombası Yoğun Onarım 400ml',
      path: 'duru-sampuan-nem-bombasi-yogun-onarim-400ml',
      price: 88.65,
    ),
  ),
  'sampuan-400__elidor': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Elidor Işıltı Serisi Şampuan 400 Ml',
      path: 'elidor-isilti-serisi-sampuan-400-ml-p-569872',
      price: 149.0,
    ),
    happyCenter: MarketProductRef(
      name: 'Elidor Biberiye Şampuan 400 Ml',
      path: 'elidor-biberiye-sampuan-400-ml',
      price: 110.9,
    ),
  ),
  'seker-2kg__altinkup': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Altınküp Toz Şeker 2000 g',
      path: 'altinkup-toz-seker-2000-g-p-5298',
      price: 94.5,
    ),
  ),
  'sosis-190__aytac': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Aytaç Dana Sosis 190 g',
      path: 'aytac-dana-sosis-190-g-p-256466',
      price: 135.0,
    ),
  ),
  'su-1-5l__erikli': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Erikli Su 1,5 lt',
      path: 'Erikli_1_5_Lt_Su_Pet',
      price: 33.2,
    ),
  ),
  'su-1-5l__hayat': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Hayat Su Pet Şişe 1,5 lt',
      path: 'Hayat_1_5_Lt_Su_Pet_Sise',
      price: 24.9,
    ),
  ),
  'su-1-5l__saka': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Saka Su 1.5 L',
      path: 'saka-su-1-5-l-p-5905',
      price: 34.9,
    ),
    happyCenter: MarketProductRef(
      name: 'Saka Su 1,5 lt Pet',
      path: 'U_saka_Su_1_5_Lt',
      price: 32.1,
    ),
  ),
  'su-5l__erikli': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Erikli Su 5 lt',
      path: 'Erikli_5_Lt_Su_Pet',
      price: 77.6,
    ),
  ),
  'su-5l__hayat': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Hayat Su Pet Şişe 5 lt',
      path: 'Hayat_5_Lt_Su_Pet_Sise',
      price: 67.7,
    ),
  ),
  'su-5l__saka': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Saka Su 5 L',
      path: 'saka-su-5-l-p-8475',
      price: 57.5,
    ),
    happyCenter: MarketProductRef(
      name: 'Saka Su 5 lt Pet',
      path: 'U_saka_Su_5_Lt',
      price: 63.75,
    ),
  ),
  'sucuk-250__aytac': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Aytaç Dilimli Dana Sucuk Isıl İşlem 250 g',
      path: 'aytac-dilimli-dana-sucuk-isil-islem-250-g-p-5602',
      price: 209.0,
    ),
  ),
  'sucuk-250__banvit': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Banvit Piliç Kangal Sucuk 250 g',
      path: 'banvit-pilic-kangal-sucuk-250-g-p-6473',
      price: 67.5,
      inStock: false,
    ),
  ),
  'sucuk-250__erpilic': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Erpiliç Piliç Kangal Sucuk 250 G',
      path: 'erpilic-pilic-kangal-sucuk-250-g-p-73258',
      price: 67.5,
    ),
  ),
  'sucuk-250__gedik': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Gedik Piliç Kangal Sucuk 250 g',
      path: 'gedik-pilic-kangal-sucuk-250-g-p-4297',
      price: 67.5,
      inStock: false,
    ),
  ),
  'sucuk-250__keskinoglu': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Keskinoğlu Kangal Sucuk 250 g',
      path: 'keskinoglu-kangal-sucuk-250-g-p-79687',
      price: 67.5,
    ),
  ),
  'sucuk-250__maret': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Maret Enfes Isıl İşlem Sucuk 250 g',
      path: 'maret-enfes-isil-islem-sucuk-250-g-p-8411',
      price: 189.0,
      inStock: false,
    ),
    happyCenter: MarketProductRef(
      name: 'Maret Dana Sucuk Kangal Fermente 250 Gr.',
      path: 'maret-dana-sucuk-kangal-fermente-400-gr-',
      price: 310.7,
    ),
  ),
  'sucuk-250__sultan': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Sultan Kangal Sucuk Isıl İşlem 250 g',
      path: 'sultan-kangal-sucuk-isil-islem-250-g-p-5651',
      price: 189.0,
    ),
  ),
  'sut-1l__icim': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'İçim Süt Tam Yağlı Uht 1 lt',
      path: 'Icim_Sut_11_Tam_Yagli',
      price: 75.95,
    ),
  ),
  'sut-1l__mis': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mis Bakraçlık Süt Tam Yağlı 1 L',
      path: 'mis-bakraclik-sut-tam-yagli-1-l-p-7501',
      price: 59.5,
    ),
  ),
  'sut-1l__pinar': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Pınar Süt Tam Yağlı Uht 1 lt',
      path: 'Pinar_Sut_11_Tam_Yagli',
      price: 88.0,
    ),
  ),
  'sut-yarim-1l__icim': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'İçim Süt Yarım Yağlı Uht 1/1',
      path: 'b--icim-sut-11-y-yagli',
      price: 65.4,
    ),
  ),
  'sut-yarim-1l__mis': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mis Uht Süt Yarım Yağlı 1 L',
      path: 'mis-uht-sut-yarim-yagli-1-l-p-5834',
      price: 41.0,
      inStock: false,
    ),
  ),
  'sut-yarim-1l__sek': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Sek Uht Süt Yarım Yağlı 1 Lt',
      path: 'sek-uht-sut-yarim-yagli-1-lt-p-4343',
      price: 39.9,
      inStock: false,
    ),
  ),
  'sut-yarim-1l__sutas': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Sütaş Süt Yarım Yağlı Uht 1/1',
      path: 'D_sutas_11_Uht_Sut_Yarim_Yagli',
      price: 63.2,
    ),
  ),
  'tavuk-1kg__gedik': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Gedik Piliç But Pirzola Kg',
      path: 'gedik-pilic-but-pirzola-kg-p-461813',
      price: 249.0,
    ),
  ),
  'tavuk-1kg__senpilic': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Şenpiliç But Pirzola kg',
      path: 'senpilic-but-pirzola-kg-p-8886',
      price: 249.0,
      inStock: false,
    ),
  ),
  'tereyag-500__icim': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'İçim Tereyağı 500 gr',
      path: 'Icim_Tereyag_500_Gr_Rulo',
      price: 510.5,
    ),
  ),
  'tereyag-500__mis': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mis Tereyağı 500 g',
      path: 'mis-tereyagi-500-g-p-7204',
      price: 279.0,
    ),
  ),
  'ton-2x160__bizim-vatan': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Ton Balığı Bizim Vatan 2*160 g',
      path: 'ton-baligi-bizim-vatan-2-160-g-p-7471',
      price: 121.0,
    ),
  ),
  'tuvalet-16__selpak': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Selpak Tuvalet Kağıdı 16\'lı',
      path: 'selpak-tuvalet-kagidi-16-li-p-4455',
      price: 199.0,
      inStock: false,
    ),
    happyCenter: MarketProductRef(
      name: 'Selpak Extra Banyo Ferahlatma  Tuvalet Kağıdı16 LI',
      path: 'selpak-extra-banyo-ferahlatma--tuvalet-kagidi16-li',
      price: 188.6,
    ),
  ),
  'tuvalet-16__solo': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Solo Bambu Katkılı Tuvalet Kağıdı 16\'lı',
      path: 'solo-bambu-katkili-tuvalet-kagidi-16-li-p-3555',
      price: 99.0,
      inStock: false,
    ),
  ),
  'tuz-500__billur': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Billur Tuz Rafine İyotlu Sofra Tuzu 500 g',
      path: 'billur-tuz-rafine-iyotlu-sofra-tuzu-500-g-p-8155',
      price: 54.5,
    ),
    happyCenter: MarketProductRef(
      name: 'Billur Tuz 500 gr + Plastik Tuzluk',
      path: 'Billur_500_Gr_Tuz_Plastik_Tuzluk',
      price: 55.4,
    ),
  ),
  'un-5kg__piyale': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Piyale Un 5 Kg',
      path: 'piyale-un-5-kg-p-8539',
      price: 135.0,
    ),
  ),
  'yogurt-1kg__eker': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Eker Yoğurt Kaymaklı Tava 1000 Gr',
      path: 'Eker_Comlek_Yogurt_1000_Gr',
      price: 148.3,
    ),
  ),
  'yogurt-1kg__icim': MarketProductEntry(
    sok: MarketProductRef(
      name: 'İçim Tam Yağlı Kaymaksız Yoğurt 1 Kg',
      path: 'icim-tam-yagli-kaymaksiz-yogurt-1-kg-p-4624',
      price: 85.9,
    ),
    happyCenter: MarketProductRef(
      name: 'İçim Yoğurt Kaymaksız 1000 Gr',
      path: 'Icim_Yogurt_1000_Gr_Kaymaksiz',
      price: 116.45,
    ),
  ),
  'yogurt-1kg__mis': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Mis Kaymaklı Yoğurt 1 kg',
      path: 'mis-kaymakli-yogurt-1-kg-p-2229',
      price: 84.9,
    ),
  ),
  'yogurt-1kg__pinar': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Pınar Yoğurt Organik 1000 gr',
      path: 'Pinar_Yogurt_1000_Gr_Organik',
      price: 171.95,
    ),
  ),
  'yogurt-1kg__sutas': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Sütaş Kaymaksız Yoğurt 1 Kg',
      path: 'sutas-kaymaksiz-yogurt-1-kg-p-7490',
      price: 89.9,
      inStock: false,
    ),
    happyCenter: MarketProductRef(
      name: 'Sütaş Yoğurt Kaymaksız 1000 gr',
      path: 'Sutas_Yogurt_1000_Gr_Kaymaksiz',
      price: 99.3,
    ),
  ),
  'yumurta-15__anadolu-ciftligi': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Anadolu Çiftliği L Yumurta 15\'li (63-72 g)',
      path: 'anadolu-ciftligi-l-yumurta-15-li-63-72-g-p-4821',
      price: 64.9,
    ),
  ),
  'yumurta-30__anadolu-ciftligi': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Anadolu Çiftliği M Yumurta 30\'lu (53-63 g)',
      path: 'anadolu-ciftligi-m-yumurta-30-lu-53-63-g-p-4948',
      price: 129.0,
    ),
  ),
  'yumusatici-1440__bingo': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Bingo Soft Manolya Bahçesi Konsantre Yumuşatıcı 1440 Ml',
      path: 'bingo-soft-manolya-bahcesi-konsantre-yumusatici-1440-ml-p-13049',
      price: 175.0,
      inStock: false,
    ),
  ),
  'yumusatici-1440__peros': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Peros Konsantre Yumuşatıcı İnci Çiçeği 1440 Ml',
      path: 'peros-konsantre-yumusatici-inci-cicegi-1440-ml-p-542785',
      price: 149.0,
    ),
  ),
  'zeytin-500__lio': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Lio Salamura Siyah Zeytin (201-260) 500 g',
      path: 'lio-salamura-siyah-zeytin-201-260-500-g-p-787',
      price: 155.0,
    ),
  ),
  'zeytinyagi-1l__komili': MarketProductEntry(
    happyCenter: MarketProductRef(
      name: 'Komili Y.Zeytinyaği Yemeklik Riviera Pet 1 Lt',
      path: 'Komili_Y_zeytinyagi_Riviera_1_Lt',
      price: 399.5,
    ),
  ),
  'zeytinyagi-1l__lio': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Lio Sızma Zeytinyağı 1 L',
      path: 'lio-sizma-zeytinyagi-1-l-p-5180',
      price: 310.0,
    ),
  ),
  'zeytinyagi-1l__yudum': MarketProductEntry(
    sok: MarketProductRef(
      name: 'Yudum Egemden Yumuşak Lezzet Sızma Zeytinyağı 1 L',
      path: 'yudum-egemden-yumusak-lezzet-sizma-zeytinyagi-1-l-p-40767',
      price: 235.9,
      inStock: false,
    ),
    happyCenter: MarketProductRef(
      name: 'Yudum Egemden Riviera Zeytinyağı Pet 1 lt',
      path: 'Yudum_Y_zeytinyagi_Riviera_1_Lt',
      price: 355.1,
    ),
  ),
};
