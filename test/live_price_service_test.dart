import 'package:flutter_test/flutter_test.dart';
import 'package:sepet_karsilastir/models/list_item.dart';
import 'package:sepet_karsilastir/models/market.dart';
import 'package:sepet_karsilastir/models/product.dart';
import 'package:sepet_karsilastir/services/catalog/catalog_client.dart';
import 'package:sepet_karsilastir/services/live_price_service.dart';
import 'package:sepet_karsilastir/services/markets/backend_market_price_client.dart';

void main() {
  const milk = Product(
    id: 'sut-1l__icim',
    typeId: 'sut-1l',
    name: 'Tam Yağlı Süt 1L',
    brand: 'İçim',
    category: 'Süt & Kahvaltı',
    unit: 'adet',
  );

  test('stubbed canlı servis tüm marketler için sonuç döner', () async {
    final service = LivePriceService.stubbed();
    final result = await service.compareBasket([
      const ListItem(product: milk, quantity: 2),
    ]);

    expect(result.baskets, hasLength(Market.all.length));
    expect(result.cheapestComplete, isNotNull);
    expect(result.cheapestComplete!.market.id, MarketId.tarimKredi);
    expect(result.failedMarketCount, 0);
  });

  test('kısmi market hatasında diğer sonuçlar korunur', () async {
    final service = LivePriceService(
      marketClients: [
        StubMarketPriceClient(marketId: MarketId.a101, priceFactor: 0.9),
        StubMarketPriceClient(marketId: MarketId.migros, shouldFail: true),
      ],
      catalogClient: LocalCatalogClient(),
    );

    final result = await service.compareBasket([
      const ListItem(product: milk),
    ]);

    expect(result.failedMarketCount, 1);
    expect(result.cheapestComplete?.market.id, MarketId.a101);
  });
}
