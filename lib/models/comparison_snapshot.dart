import 'comparison_result.dart';
import 'list_item.dart';
import 'market.dart';

/// Geçmişte kaydedilen tek bir market toplamı.
class MarketTotalSnapshot {
  const MarketTotalSnapshot({
    required this.marketId,
    required this.total,
    required this.isComplete,
    required this.missingCount,
  });

  static MarketTotalSnapshot? fromJson(Map<String, dynamic> json) {
    final id = Market.idFromName(json['marketId'] as String?);
    if (id == null) return null;
    return MarketTotalSnapshot(
      marketId: id,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
      missingCount: (json['missingCount'] as num?)?.toInt() ?? 0,
    );
  }

  final MarketId marketId;
  final double total;
  final bool isComplete;
  final int missingCount;

  Market get market => Market.byId(marketId);

  Map<String, dynamic> toJson() => {
        'marketId': marketId.name,
        'total': total,
        'isComplete': isComplete,
        'missingCount': missingCount,
      };
}

/// Tamamlanmış bir karşılaştırmanın kalıcı özeti.
///
/// Sepet kalemleri de saklanır; kullanıcı geçmiş bir karşılaştırmayı
/// sepete geri yükleyebilir.
class ComparisonSnapshot {
  const ComparisonSnapshot({
    required this.id,
    required this.comparedAt,
    required this.items,
    required this.marketTotals,
    required this.source,
    this.winnerMarketId,
    this.winnerTotal,
    this.savings,
  });

  factory ComparisonSnapshot.fromResult(
    ComparisonResult result, {
    required List<ListItem> items,
    required String id,
  }) {
    final winner = result.cheapestComplete;
    return ComparisonSnapshot(
      id: id,
      comparedAt: result.comparedAt,
      items: items,
      marketTotals: result.ranked
          .where((b) => !b.fetchFailed)
          .map(
            (b) => MarketTotalSnapshot(
              marketId: b.market.id,
              total: b.total,
              isComplete: b.isComplete,
              missingCount: b.missingCount,
            ),
          )
          .toList(),
      source: result.source,
      winnerMarketId: winner?.market.id,
      winnerTotal: winner?.total,
      savings: result.savingsVsMostExpensive,
    );
  }

  factory ComparisonSnapshot.fromJson(Map<String, dynamic> json) {
    return ComparisonSnapshot(
      id: json['id'] as String,
      comparedAt: DateTime.parse(json['comparedAt'] as String),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      marketTotals: (json['marketTotals'] as List<dynamic>? ?? [])
          .map((e) => MarketTotalSnapshot.fromJson(e as Map<String, dynamic>))
          .whereType<MarketTotalSnapshot>()
          .toList(),
      source: json['source'] == 'live'
          ? PriceSource.live
          : PriceSource.priceBook,
      winnerMarketId: Market.idFromName(json['winnerMarketId'] as String?),
      winnerTotal: (json['winnerTotal'] as num?)?.toDouble(),
      savings: (json['savings'] as num?)?.toDouble(),
    );
  }

  final String id;
  final DateTime comparedAt;
  final List<ListItem> items;
  final List<MarketTotalSnapshot> marketTotals;
  final PriceSource source;
  final MarketId? winnerMarketId;
  final double? winnerTotal;
  final double? savings;

  Market? get winnerMarket =>
      winnerMarketId == null ? null : Market.byId(winnerMarketId!);

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'comparedAt': comparedAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'marketTotals': marketTotals.map((e) => e.toJson()).toList(),
        'source': source == PriceSource.live ? 'live' : 'priceBook',
        if (winnerMarketId != null) 'winnerMarketId': winnerMarketId!.name,
        if (winnerTotal != null) 'winnerTotal': winnerTotal,
        if (savings != null) 'savings': savings,
      };
}
