import '../models/product.dart';
import 'mock_catalog.dart';

/// Fiyat defterinde en az bir markette kaydı olan örnek alışveriş listesi.
///
/// Yeni kullanıcılar markasız satırlarla fiyat görebilsin diye yüksek kapsamlı
/// ürünler seçildi (çoğu 4–5 markette fiyatlanır).
List<Product> sampleBasketProducts() => [
      productTypes.firstWhere((t) => t.id == 'sut-yarim-1l').withBrand(null),
      productTypes.firstWhere((t) => t.id == 'aycicek-1l').withBrand(null),
      productTypes.firstWhere((t) => t.id == 'yumurta-15').withBrand(null),
      productTypes.firstWhere((t) => t.id == 'pirinc-1kg').withBrand(null),
      productTypes.firstWhere((t) => t.id == 'makarna-500').withBrand(null),
    ];
