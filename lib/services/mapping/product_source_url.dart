import '../../models/market.dart';
import '../../models/product.dart';
import '../../models/product_link.dart';
import '../../utils/text.dart';

/// Fiyatı olmayan satır için marketin arama bağlantısını üretir.
///
/// Fiyatlı satırın bağlantısı buradan gelmez: o bağlantı fiyatın okunduğu ürün
/// sayfasıdır ve fiyat defterinde tutulur. Burada üretilen bağlantı yalnızca
/// "bu markette fiyat bulamadım, sen bakmak ister misin" içindir; bu yüzden
/// yanına hiçbir zaman tutar yazılmaz.
class ProductSourceUrl {
  const ProductSourceUrl._();

  /// Marketin site içi araması varsa arama, yoksa kendi ana sayfası.
  static ProductLink search({
    required MarketId marketId,
    required Product product,
  }) {
    final query = searchQuery(product);
    final market = Market.byId(marketId);
    return switch (marketId) {
      MarketId.sok =>
        _search('https://www.sokmarket.com.tr/arama', 'q', query),
      MarketId.happyCenter =>
        // Happy Center araması /Product/Search/ altında `ara` parametresiyle.
        _search('https://happycenter.com.tr/Product/Search/', 'ara', query),
      MarketId.hakmar =>
        _search('https://www.hakmarexpress.com.tr/arama', 'q', query),
      MarketId.migros => _search('https://www.migros.com.tr/arama', 'q', query),
      MarketId.macrocenter =>
        _search('https://www.macrocenter.com.tr/arama', 'q', query),
      MarketId.a101 => _search('https://www.a101.com.tr/arama', 'k', query),
      MarketId.carrefour =>
        _search('https://www.carrefoursa.com/search/', 'text', query),
      // Kalan marketlerin sitesinde URL ile tetiklenen ürün araması yok.
      MarketId.bim || MarketId.tarimKredi =>
        ProductLink(url: market.site, kind: ProductLinkKind.site),
    };
  }

  /// Aranacak metin: marka + ürün adı; birim her zaman sorgunun içinde kalır.
  static String searchQuery(Product product) {
    final brand = product.brand?.trim();
    if (brand == null || brand.isEmpty || isGenericBrand(brand)) {
      return product.name;
    }
    return '$brand ${product.name}';
  }

  /// Marka belirtilmemiş satır mı?
  ///
  /// `market-markasi` artık katalogda yok; eski sepetlerden yüklenen satırlar
  /// için tanınmaya devam ediyor.
  static bool isGenericBrand(String? brand) {
    if (brand == null || brand.trim().isEmpty) return true;
    final key = slugifyTurkish(brand);
    return key.isEmpty || key == 'markasiz' || key == 'market-markasi';
  }

  static ProductLink _search(String base, String param, String query) {
    final url =
        Uri.parse(base).replace(queryParameters: {param: query}).toString();
    return ProductLink(url: url, kind: ProductLinkKind.search);
  }
}
