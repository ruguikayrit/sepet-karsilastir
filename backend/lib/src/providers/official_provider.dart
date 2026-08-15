import '../catalog.dart';

/// Tek bir market zinciri için resmi fiyat kaynağı.
///
/// Uygulama / web sitesi private API’lerini scrap etmek veya reverse-engineer
/// etmek desteklenmez. Adaptör yalnızca marketin sağladığı resmi API,
/// partner feed veya sözleşmeli veri kanalına bağlanır.
abstract class OfficialMarketProvider {
  String get slug;
  String get displayName;

  /// Resmi kimlik bilgisi / endpoint yapılandırıldı mı?
  bool get isConfigured;

  /// Yapılandırılmamışsa neden (log / health için).
  String get configurationHint;

  Future<MarketQuoteResult> fetchQuotes({
    required List<QuoteItem> items,
    String? region,
    String? storeId,
  });
}

class QuoteItem {
  const QuoteItem({
    required this.productId,
    required this.typeId,
    this.brand,
    this.name,
    this.externalSku,
    this.quantity = 1,
  });

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    final productId = json['productId'] as String? ?? '';
    final typeId = json['typeId'] as String? ??
        (productId.contains('__')
            ? productId.split('__').first
            : productId);
    return QuoteItem(
      productId: productId,
      typeId: typeId,
      brand: json['brand'] as String?,
      name: json['name'] as String?,
      externalSku: json['externalSku'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  final String productId;
  final String typeId;
  final String? brand;
  final String? name;
  final String? externalSku;
  final int quantity;

  ProductType? get catalogType => typeById(typeId);
}

class LineQuote {
  const LineQuote({
    required this.productId,
    required this.unitPrice,
    required this.available,
    this.externalSku,
    this.currency = 'TRY',
    this.matchedTitle,
    this.depotName,
  });

  final String productId;
  final double unitPrice;
  final bool available;
  final String? externalSku;
  final String currency;
  final String? matchedTitle;
  final String? depotName;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'externalSku': externalSku,
        'unitPrice': unitPrice,
        'available': available,
        'currency': currency,
        if (matchedTitle != null) 'matchedTitle': matchedTitle,
        if (depotName != null) 'depotName': depotName,
      };
}

class MarketQuoteResult {
  const MarketQuoteResult({
    required this.marketId,
    required this.status,
    required this.fetchedAt,
    required this.quotes,
    this.storeId,
    this.errorMessage,
    this.source,
  });

  final String marketId;
  final String status; // ok | failed
  final DateTime fetchedAt;
  final List<LineQuote> quotes;
  final String? storeId;
  final String? errorMessage;
  final String? source;

  Map<String, dynamic> toJson() => {
        'marketId': marketId,
        'status': status,
        'fetchedAt': fetchedAt.toUtc().toIso8601String(),
        if (storeId != null) 'storeId': storeId,
        if (errorMessage != null) 'errorMessage': errorMessage,
        if (source != null) 'source': source,
        'quotes': quotes.map((e) => e.toJson()).toList(),
      };

  factory MarketQuoteResult.failed({
    required String marketId,
    required String message,
  }) {
    return MarketQuoteResult(
      marketId: marketId,
      status: 'failed',
      fetchedAt: DateTime.now(),
      quotes: const [],
      errorMessage: message,
    );
  }
}
