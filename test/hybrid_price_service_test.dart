import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/data/mock_catalog.dart';
import 'package:sepet_karsilastir/models/comparison_result.dart';
import 'package:sepet_karsilastir/models/fetch_status.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/services/hybrid_price_service.dart';
import 'package:sepet_karsilastir/services/http/api_client.dart';
import 'package:sepet_karsilastir/services/price_book_service.dart';

/// NDJSON akışını taklit eder.
class _FakeApiClient extends ApiClient {
  _FakeApiClient(this.chunks)
      : super(
          baseUrl: 'https://api.test.local',
          httpClient: null,
        );

  final List<Map<String, dynamic>> chunks;

  @override
  Stream<Map<String, dynamic>> postNdjsonStream(
    String path,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async* {
    for (final chunk in chunks) {
      yield chunk;
    }
  }
}

void main() {
  final oil =
      productTypes.firstWhere((t) => t.id == 'aycicek-1l').withBrand('Evin');
  final items = [ListItem(product: oil)];

  test('API yoksa yalnızca defter önizlemesi döner', () async {
    final service = HybridPriceService(
      book: const PriceBookService(),
      apiClient: null,
    );

    final snapshots = await service.watchBasketComparison(items).toList();

    expect(snapshots.length, 1);
    expect(snapshots.single.refreshing, isFalse);
    expect(snapshots.single.source, PriceSource.priceBook);
  });

  test('API varsa defter anında gelir, sonra market güncellenir', () async {
    final service = HybridPriceService(
      book: const PriceBookService(),
      apiClient: _FakeApiClient([
        {
          'event': 'market',
          'pricesFetchedAt': '2026-07-27T08:00:00Z',
          'market': {
            'marketId': 'sok',
            'status': 'ok',
            'fetchedAt': '2026-07-27T08:00:00Z',
            'quotes': [
              {
                'productId': oil.id,
                'unitPrice': 122.0,
                'available': true,
                'marketProduct': 'Evin Ayçiçek Yağı 1 L',
                'sourceUrl':
                    'https://www.sokmarket.com.tr/evin-aycicek-yagi-1-l-p-1234',
              },
            ],
          },
        },
        {'event': 'done'},
      ]),
    );

    final snapshots = await service.watchBasketComparison(items).toList();

    expect(snapshots.length, greaterThanOrEqualTo(2));
    expect(snapshots.first.refreshing, isTrue);
    expect(snapshots.first.source, PriceSource.priceBook);

    final last = snapshots.last;
    expect(last.refreshing, isFalse);
    expect(last.source, PriceSource.live);
    final sok = last.baskets.firstWhere((b) => b.market.id == MarketId.sok);
    expect(sok.status, FetchStatus.ok);
    expect(sok.lines.single.unitPrice, 122.0);
  });

  test('canlı yanıt boşsa defter fiyatları silinmez', () async {
    final service = HybridPriceService(
      book: const PriceBookService(),
      apiClient: _FakeApiClient([
        {
          'event': 'market',
          'market': {
            'marketId': 'sok',
            'status': 'ok',
            'fetchedAt': '2026-07-27T08:00:00Z',
            'quotes': [],
          },
        },
        {'event': 'done'},
      ]),
    );

    final snapshots = await service.watchBasketComparison(items).toList();
    final last = snapshots.last;
    final sok = last.baskets.firstWhere((b) => b.market.id == MarketId.sok);
    expect(sok.lines.single.unitPrice, 122.0);
    expect(sok.lines.single.available, isTrue);
  });
}
