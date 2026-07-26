import '../../data/market_price_snapshot.dart';
import '../../data/market_product_snapshot.dart';
import '../../models/market.dart';
import '../../models/product.dart';
import '../../models/product_link.dart';
import '../../utils/text.dart';

/// Karşılaştırma satırının fiyatını doğrulayacak market bağlantısını üretir.
///
/// Sıra:
/// 1. O markette marka + birim birebir eşleşen ürün sayfası ([marketProductSnapshot])
/// 2. Markasız/market markası satırlarda tip seviyesindeki ürün sayfası
/// 3. Market site içi arama sunuyorsa marka + birimli arama
/// 4. Aksi halde marketin kendi sitesi
///
/// Bağlantı her zaman ilgili marketin kendi alan adına gider.
class ProductSourceUrl {
  const ProductSourceUrl._();

  static const sokHost = 'https://www.sokmarket.com.tr';
  static const happyCenterHost = 'https://happycenter.com.tr';

  static ProductLink resolve({
    required MarketId marketId,
    required Product product,
  }) {
    final query = searchQuery(product);
    return switch (marketId) {
      MarketId.sok => _sok(product, query),
      MarketId.happyCenter => _happyCenter(product, query),
      MarketId.migros => _search('https://www.migros.com.tr/arama', 'q', query),
      MarketId.macrocenter =>
        _search('https://www.macrocenter.com.tr/arama', 'q', query),
      MarketId.a101 => _search('https://www.a101.com.tr/arama', 'k', query),
      MarketId.carrefour =>
        _search('https://www.carrefoursa.com/search/', 'text', query),
      MarketId.hakmar =>
        _search('https://www.hakmarexpress.com.tr/arama', 'q', query),
      // Aşağıdaki marketlerin sitesinde URL ile tetiklenen ürün araması yok;
      // yalnızca marketin kendi ana sayfası açılır.
      MarketId.bim => _site('https://www.bim.com.tr/'),
      MarketId.file => _site('https://www.file.com.tr/'),
      MarketId.tarimKredi => _site('https://www.tkkoop.com.tr/'),
      MarketId.onur => _site('https://www.onurmarket.com/'),
      MarketId.metro => _site('https://www.metro-tr.com/'),
      MarketId.getir => _site('https://getir.com/buyuk/'),
    };
  }

  /// Marka + ürün adı; birim ürün adında sabittir (ör. 500g, 1L).
  static String searchQuery(Product product) {
    final brand = product.brand?.trim();
    if (brand == null || brand.isEmpty || isGenericBrand(brand)) {
      return product.name;
    }
    return '$brand ${product.name}';
  }

  /// Markasız veya market markası satırı mı?
  static bool isGenericBrand(String? brand) {
    if (brand == null || brand.trim().isEmpty) return true;
    final key = foldBrand(brand);
    return key.isEmpty || key == 'markasiz' || key == 'market-markasi';
  }

  /// Türkçe karakterleri ASCII'ye katlar (eşleştirme için).
  static String foldBrand(String brand) => slugifyTurkish(brand);

  static ProductLink _search(String base, String param, String query) {
    final url =
        Uri.parse(base).replace(queryParameters: {param: query}).toString();
    return ProductLink(url: url, kind: ProductLinkKind.search);
  }

  static ProductLink _site(String url) =>
      ProductLink(url: url, kind: ProductLinkKind.site);

  static ProductLink _product(String url) =>
      ProductLink(url: url, kind: ProductLinkKind.product);

  static ProductLink _sok(Product product, String query) {
    final path = marketProductSnapshot[product.id]?.sok?.path ??
        (isGenericBrand(product.brand)
            ? marketPriceSnapshot[product.typeId]?.sokPath
            : null);
    if (path != null) return _product('$sokHost/$path');
    return _search('$sokHost/arama', 'q', query);
  }

  static ProductLink _happyCenter(Product product, String query) {
    final path = marketProductSnapshot[product.id]?.happyCenter?.path ??
        (isGenericBrand(product.brand)
            ? marketPriceSnapshot[product.typeId]?.happyCenterPath
            : null);
    if (path != null) return _product('$happyCenterHost/$path');
    // Happy Center araması /Product/Search/ altında `ara` parametresiyle çalışır.
    return _search('$happyCenterHost/Product/Search/', 'ara', query);
  }
}
