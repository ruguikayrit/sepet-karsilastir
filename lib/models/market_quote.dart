import 'fetch_status.dart';
import 'market.dart';

/// Tek ürün için bir marketten gelen ham fiyat.
class ProductQuote {
  const ProductQuote({
    required this.productId,
    required this.unitPrice,
    required this.available,
    this.externalSku,
    this.currency = 'TRY',
  });

  final String productId;
  final String? externalSku;
  final double unitPrice;
  final bool available;
  final String currency;

  factory ProductQuote.fromJson(Map<String, dynamic> json) {
    return ProductQuote(
      productId: json['productId'] as String,
      externalSku: json['externalSku'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      available: json['available'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'TRY',
    );
  }
}

/// Bir marketin sepet teklifi (canlı kaynaktan).
class MarketQuoteBatch {
  const MarketQuoteBatch({
    required this.marketId,
    required this.quotes,
    required this.status,
    required this.fetchedAt,
    this.errorMessage,
    this.storeId,
  });

  final MarketId marketId;
  final List<ProductQuote> quotes;
  final FetchStatus status;
  final DateTime fetchedAt;
  final String? errorMessage;
  final String? storeId;

  factory MarketQuoteBatch.failed({
    required MarketId marketId,
    required String message,
    DateTime? fetchedAt,
  }) {
    return MarketQuoteBatch(
      marketId: marketId,
      quotes: const [],
      status: FetchStatus.failed,
      fetchedAt: fetchedAt ?? DateTime.now(),
      errorMessage: message,
    );
  }

  factory MarketQuoteBatch.fromJson(Map<String, dynamic> json) {
    final quotesJson = json['quotes'] as List<dynamic>? ?? const [];
    return MarketQuoteBatch(
      marketId: MarketId.values.byName(json['marketId'] as String),
      quotes: quotesJson
          .map((e) => ProductQuote.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: FetchStatus.values.byName(json['status'] as String? ?? 'ok'),
      fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? '') ??
          DateTime.now(),
      errorMessage: json['errorMessage'] as String?,
      storeId: json['storeId'] as String?,
    );
  }
}

/// Backend katalog arama sonucu satırı.
class CatalogHit {
  const CatalogHit({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    this.brand,
  });

  final String id;
  final String name;
  final String category;
  final String unit;
  final String? brand;

  factory CatalogHit.fromJson(Map<String, dynamic> json) {
    return CatalogHit(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Genel',
      unit: json['unit'] as String? ?? 'adet',
      brand: json['brand'] as String?,
    );
  }
}
