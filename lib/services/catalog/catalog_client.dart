import '../../data/mock_catalog.dart';
import '../http/api_client.dart';

/// Ürün tipi arama / katalog.
abstract class CatalogClient {
  Future<List<ProductType>> search(String query);
}

/// `GET /v1/catalog/search?q=`
class BackendCatalogClient implements CatalogClient {
  BackendCatalogClient(this._api);

  final ApiClient _api;

  @override
  Future<List<ProductType>> search(String query) async {
    final json = await _api.getJson(
      '/v1/catalog/search',
      query: {'q': query},
    );
    final items = json['items'] as List<dynamic>? ?? const [];
    return items.map((raw) {
      final map = raw as Map<String, dynamic>;
      return ProductType(
        id: map['id'] as String,
        name: map['name'] as String,
        category: map['category'] as String? ?? 'Genel',
        unit: map['unit'] as String? ?? 'adet',
      );
    }).toList();
  }
}

/// Backend hazır değilken yerel katalog.
class LocalCatalogClient implements CatalogClient {
  @override
  Future<List<ProductType>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return searchProductTypesLocal(query);
  }
}
