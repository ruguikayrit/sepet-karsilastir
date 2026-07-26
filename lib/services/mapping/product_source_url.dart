import '../../data/market_price_snapshot.dart';
import '../../models/market.dart';
import '../../models/product.dart';

/// Karşılaştırma satırı için fiyatın bakılacağı market ürün / arama URL’si.
///
/// - Şok ve Happy Center: bilinen ürün sayfası (marka + birim eşleşirse)
/// - Diğer marketler: resmi sitede aynı marka + ürün adı (birim dahil) araması
///
/// Şok satırına tıklanınca her zaman `sokmarket.com.tr` açılır; aranan
/// ürün adındaki gramaj/hacim (ör. 500g) korunur.
class ProductSourceUrl {
  const ProductSourceUrl._();

  /// typeId → (katlanmış marka → Şok ürün yolu)
  static const sokBrandPaths = <String, Map<String, String>>{
    'sut-1l': {
      'mis': 'mis-bakraclik-sut-tam-yagli-1-l-p-7501',
      'icim': 'icim-organik-sut-1-l-p-7796',
      'pinar': 'pinar-sut-1-yagli-1-l-p-3670',
    },
    'sut-yarim-1l': {
      'mis': 'mis-uht-sut-3-1-yagli-1-l-p-8533',
    },
    'kasar-500': {
      'sutas': 'sutas-kasar-peyniri-500-g-p-4684',
      'mis': 'mis-tam-yagli-kasar-peyniri-500-g-p-8768',
    },
    'peynir-500': {
      'mis': 'mis-tam-yagli-beyaz-peynir-500-g-p-7382',
    },
    'yogurt-1kg': {
      'icim': 'icim-tam-yagli-kaymaksiz-yogurt-1-kg-p-4624',
    },
    'cay-500': {
      'caykur': 'caykur-cay-cicegi-500-g-p-48713',
    },
    'cay-1000': {
      'lipton': 'lipton-yellow-label-cay-1000-g-p-5132',
    },
    'kola-1l': {
      'coca-cola': 'coca-cola-1-l-p-4687',
    },
    'kola-2-5l': {
      'cola-turka': 'cola-turka-2-5-l-p-5546',
    },
    'makarna-500': {
      'nuhun-ankara': 'nuh-un-ankara-vitaminli-spaghetti-500-g-p-8012',
      'nuh-un-ankara': 'nuh-un-ankara-vitaminli-spaghetti-500-g-p-8012',
    },
    'makarna-penne': {
      'barilla': 'barilla-penne-rigate-kalem-makarna-500-g-p-4733',
    },
    'sampuan-400': {
      'elidor': 'elidor-isilti-serisi-sampuan-400-ml-p-569872',
    },
    'dis-macunu': {
      'colgate': 'colgate-max-white-purple-dis-macunu-75-ml-p-321160',
    },
    'deterjan-1-5kg': {
      'omo': 'omo-matik-color-toz-deterjan-1-5-kg-p-5366',
    },
    'cips-150': {
      'amigo': 'amigo-duz-sade-patates-cipsi-150-g-p-4767',
      'ruffles': 'ruffles-originals-sade-patates-cipsi-125-g-p-424472',
    },
    'kraker-82': {
      'ulker': 'ulker-cizivic-kraker-peynirli-sandvic-82-g-p-7091',
    },
    'sucuk-250': {
      'aytac': 'aytac-ciftlik-kangal-sucuk-isil-islem-250-g-p-45889',
    },
    'salam-60': {
      'namet': 'namet-dana-macar-salam-60-g-p-6063',
    },
    'pilic-butun': {
      'gedik': 'gedik-butun-pilic-kg-p-440564',
    },
    'pilic-but': {
      'gedik': 'gedik-pilic-kalcali-but-kg-p-460899',
    },
    'dondurma-500': {
      'algida': 'algida-maras-usulu-sade-dondurma-500-ml-p-8891',
    },
  };

  static String resolve({
    required MarketId marketId,
    required Product product,
  }) {
    final query = searchQuery(product);
    return switch (marketId) {
      MarketId.sok => _sok(product, query),
      MarketId.happyCenter => _happyCenter(product, query),
      MarketId.migros => _search(
          'https://www.migros.com.tr/arama',
          'q',
          query,
        ),
      MarketId.macrocenter => _search(
          'https://www.migros.com.tr/arama',
          'q',
          query,
        ),
      MarketId.a101 => _search(
          'https://www.a101.com.tr/arama',
          'q',
          query,
        ),
      MarketId.bim => 'https://www.bim.com.tr/',
      MarketId.carrefour => _search(
          'https://www.carrefoursa.com/search/',
          'text',
          query,
        ),
      MarketId.file => 'https://www.file.com.tr/',
      MarketId.tarimKredi => 'https://www.tarimkredimarketleri.com.tr/',
      MarketId.hakmar => 'https://www.hakmar.com.tr/',
      MarketId.onur => 'https://kurumsal.onurmarket.com/',
      MarketId.metro => _search(
          'https://www.metro-tr.com/search',
          'q',
          query,
        ),
      MarketId.getir => _search(
          'https://getir.com/arama/',
          'keyword',
          query,
        ),
    };
  }

  /// Marka + ürün adı (birim ürün adında sabittir, örn. 500g / 1L).
  static String searchQuery(Product product) {
    final brand = product.brand?.trim();
    if (brand == null ||
        brand.isEmpty ||
        foldBrand(brand) == 'market-markasi') {
      return product.name;
    }
    return '$brand ${product.name}';
  }

  /// Türkçe karakterleri ASCII’ye katlar (eşleştirme için).
  static String foldBrand(String brand) {
    final lower = brand
        .toLowerCase()
        // Dart’ta 'İ'.toLowerCase() → i + combining dot
        .replaceAll('\u0307', '')
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('û', 'u');
    return lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  static String _search(String base, String param, String query) {
    return Uri.parse(base).replace(queryParameters: {param: query}).toString();
  }

  static String _sok(Product product, String query) {
    final brandKey = foldBrand(product.brand ?? '');
    final brandPath = sokBrandPaths[product.typeId]?[brandKey];
    if (brandPath != null) {
      return 'https://www.sokmarket.com.tr/$brandPath';
    }

    final ref = marketPriceSnapshot[product.typeId];
    final brandMissing =
        brandKey.isEmpty || brandKey == 'market-markasi' || brandKey == 'markasiz';
    if (brandMissing && ref?.sokPath != null) {
      return 'https://www.sokmarket.com.tr/${ref!.sokPath}';
    }

    // Markalı ama bilinen SKU yok: Şok aramada marka + birimli ad.
    return _search('https://www.sokmarket.com.tr/arama', 'q', query);
  }

  static String _happyCenter(Product product, String query) {
    final ref = marketPriceSnapshot[product.typeId];
    final brandKey = foldBrand(product.brand ?? '');
    final brandMissing =
        brandKey.isEmpty || brandKey == 'market-markasi' || brandKey == 'markasiz';

    if (product.category == 'Meyve & Sebze' && ref?.happyCenterPath != null) {
      return 'https://happycenter.com.tr/${ref!.happyCenterPath}';
    }
    if (brandMissing && ref?.happyCenterPath != null) {
      return 'https://happycenter.com.tr/${ref!.happyCenterPath}';
    }
    return Uri.https(
      'happycenter.com.tr',
      '/index.php',
      {'route': 'product/search', 'search': query},
    ).toString();
  }
}
