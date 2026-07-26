import '../../data/mock_catalog.dart';
import '../../models/market_quote.dart';
import '../../models/product.dart';
import '../http/api_client.dart';

/// Ürün arama / katalog.
abstract class CatalogClient {
  Future<List<Product>> search(String query);
}

/// `GET /v1/catalog/search?q=`
class BackendCatalogClient implements CatalogClient {
  BackendCatalogClient(this._api);

  final ApiClient _api;

  @override
  Future<List<Product>> search(String query) async {
    final json = await _api.getJson(
      '/v1/catalog/search',
      query: {'q': query},
    );
    final items = json['items'] as List<dynamic>? ?? const [];
    return items.map((raw) {
      final hit = CatalogHit.fromJson(raw as Map<String, dynamic>);
      return Product(
        id: hit.id,
        name: hit.name,
        category: hit.category,
        unit: hit.unit,
        brand: hit.brand,
      );
    }).toList();
  }
}

/// Backend hazır değilken yerel katalog.
class LocalCatalogClient implements CatalogClient {
  @override
  Future<List<Product>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return mockCatalog;
    return mockCatalog.where((p) {
      return p.displayName.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }
}
