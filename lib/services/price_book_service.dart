import '../data/mock_catalog.dart';
import '../data/price_book.dart';
import '../models/comparison_result.dart';
import '../models/fetch_status.dart';
import '../models/list_item.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/product_link.dart';
import 'mapping/product_source_url.dart';
import 'price_service.dart';

/// Fiyat defterinden karşılaştırma üreten servis.
///
/// Tek kural: bir satır ancak o marketin kendi ürün sayfasından okunmuş fiyatı
/// varsa fiyatlanır ([priceBook]). Fiyat, satıra dokununca açılan sayfanın
/// fiyatıdır; kullanıcı tıklayıp doğrulayabilir. Fiyat yoksa tahmin
/// üretilmez — satırda "ürün bulunamadı" yazar ve toplama girmez.
///
/// Karşılaştırma bütün marketleri kapsar. Fiyatı okunamayan market listeden
/// düşmez, sebebiyle birlikte listede kalır: kullanıcı hangi marketin
/// bakıldığını ve neden tutar yazmadığını görsün.
class PriceBookService implements PriceService {
  const PriceBookService();

  @override
  Future<List<ProductType>> searchProductTypes(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return searchProductTypesLocal(query);
  }

  /// Bu markette bir ürünün fiyatı neden bulunamıyor? Bulunabiliyorsa `null`.
  ///
  /// İki sebep var: market fiyatını kendi sitesinde hiç yayınlamıyor ya da son
  /// çekimde sitesinden fiyat okunamadı. İkisi de kullanıcıya yazılır —
  /// "ürün bulunamadı" tek başına, marketin rafında o ürün yok gibi okunabilir.
  static String? noPriceReasonFor(MarketId marketId) {
    final market = Market.byId(marketId);
    if (market.noPriceReason != null) return market.noPriceReason;
    if (!priceBookMarkets.contains(marketId)) {
      return 'son çekimde sitesinden fiyat okunamadı';
    }
    return null;
  }

  /// Hiç fiyat gösterilemeyen marketler ve sebepleri.
  static Map<Market, String> get withoutPrices => {
        for (final market in Market.all)
          if (noPriceReasonFor(market.id) != null)
            market: noPriceReasonFor(market.id)!,
      };

  @override
  Future<ComparisonResult> compareBasket(List<ListItem> items) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();

    final baskets = Market.all.map((market) {
      return MarketBasketResult(
        market: market,
        lines: items
            .map((item) => line(market.id, item.product, item.quantity))
            .toList(),
        fetchedAt: now,
        status: FetchStatus.ok,
      );
    }).toList();

    return ComparisonResult(
      baskets: baskets,
      comparedAt: now,
      source: PriceSource.priceBook,
      pricesFetchedAt: priceBookFetchedAt,
    );
  }

  /// Tek bir satırın bir marketteki fiyatı.
  ///
  /// Defterde kayıt varsa fiyat ve ürün bağlantısı o kayıttan gelir. Kayıt
  /// yoksa ya da ürün stokta değilse satır fiyatsızdır; bağlantı marketin
  /// arama sayfasına gider, ama fiyat gösterilmez.
  LinePrice line(MarketId marketId, Product product, int quantity) {
    final offer = offerFor(marketId, product);
    if (offer == null || !offer.inStock) {
      return LinePrice(
        product: product,
        quantity: quantity,
        source: ProductSourceUrl.search(marketId: marketId, product: product),
      );
    }
    return LinePrice(
      product: product,
      quantity: quantity,
      unitPrice: offer.price,
      marketProduct: offer.product,
      source: ProductLink(url: offer.url, kind: ProductLinkKind.product),
    );
  }

  /// Bu marketin bu ürün için yayınladığı kayıt.
  static MarketOffer? offerFor(MarketId marketId, Product product) =>
      priceBook[product.id]?[marketId];

  /// Bu ürünü kaç market fiyatlıyor?
  ///
  /// Sepete eklerken işe yarar: hiçbir markette fiyatı olmayan bir marka
  /// seçildiyse karşılaştırma o satır için boş kalacak, kullanıcı bunu
  /// eklemeden önce görsün.
  static int pricedMarketCount(String productId) =>
      priceBook[productId]?.values.where((offer) => offer.inStock).length ?? 0;
}
