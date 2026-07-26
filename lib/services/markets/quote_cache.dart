import '../../models/list_item.dart';
import '../../models/market.dart';
import '../../models/market_quote.dart';
import '../../models/fetch_status.dart';

/// Kısa ömürlü sepet teklif önbelleği.
///
/// Aynı ürün seti birkaç saniye içinde tekrar karşılaştırıldığında
/// gereksiz ağ çağrısını engeller. Market bazında tutulur.
class QuoteCache {
  QuoteCache({this.ttl = const Duration(seconds: 45)});

  final Duration ttl;
  final Map<String, _Entry> _entries = {};

  String keyFor({
    required MarketId marketId,
    required List<ListItem> items,
    String? region,
    String? storeId,
  }) {
    final parts = items.map((i) => '${i.product.id}:${i.quantity}').toList()
      ..sort();
    return '${marketId.name}|${region ?? ''}|${storeId ?? ''}|${parts.join(',')}';
  }

  MarketQuoteBatch? read(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _entries.remove(key);
      return null;
    }
    return entry.batch;
  }

  void write(String key, MarketQuoteBatch batch) {
    if (batch.status.isFailed) return;
    _entries[key] = _Entry(
      batch: batch,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  void clear() => _entries.clear();
}

class _Entry {
  const _Entry({required this.batch, required this.expiresAt});

  final MarketQuoteBatch batch;
  final DateTime expiresAt;
}
