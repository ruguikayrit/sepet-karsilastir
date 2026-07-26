import '../data/market_price_index.dart';
import '../data/market_price_snapshot.dart';
import '../data/market_product_snapshot.dart';
import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/fetch_status.dart';
import '../models/list_item.dart';
import '../models/market.dart';
import '../models/product.dart';
import 'mapping/product_source_url.dart';
import 'price_service.dart';

/// Demo / geliştirme fiyat motoru.
///
/// Kullanıcı sepete "marka + birim" seçerek girer; bu servis aynı ürünün
/// 13 markette ne tutacağını üretir. İki farklı doğruluk seviyesi vardır:
///
/// 1. **Doğrulanmış satır** — fiyat marketin kendi yayınından gelir:
///    - Şok Market ve Happy Center ürün sayfaları ([marketProductSnapshot],
///      markasız satırlarda [marketPriceSnapshot] tip kaydı),
///    - BİM, A101, Şok, Migros, CarrefourSA, Hakmar ve Tarım Kredi için
///      marketfiyati.org.tr fiyat indeksi ([marketPriceIndex]).
/// 2. **Türetilmiş satır** — kalan marketlerde referans birim fiyat
///    ([marketPriceSnapshot] ya da markanın doğrulanmış fiyat ortalaması)
///    market fiyat seviyesi ve deterministik bir sapma ile ölçeklenir.
///    Bu satırlar [LinePrice.verified] `false` ile işaretlenir; ekran
///    toplamı "yaklaşık" gösterir.
///
/// Birim hiçbir zaman değişmez: ürün adındaki gramaj tüm satırlarda aynıdır,
/// farklı gramaj ayrı bir ürün tipidir. Satır bağlantıları [ProductSourceUrl]
/// ile daima ilgili marketin kendi alan adına gider.
class MockPriceService implements PriceService {
  /// Marketin genel fiyat seviyesi (1.0 ≈ snapshot kaynak marketleri).
  static const _marketIndex = <MarketId, double>{
    MarketId.bim: 0.97,
    MarketId.a101: 0.99,
    MarketId.sok: 1.00,
    MarketId.hakmar: 0.98,
    MarketId.tarimKredi: 0.95,
    MarketId.metro: 1.01,
    MarketId.file: 1.05,
    MarketId.onur: 1.04,
    MarketId.happyCenter: 1.00,
    MarketId.migros: 1.12,
    MarketId.carrefour: 1.13,
    MarketId.getir: 1.19,
    MarketId.macrocenter: 1.32,
  };

  /// Marketin taşımadığı ürün tipleri.
  ///
  /// Kürasyon: kimlikler katalogla birlikte güncel kalmalı, yoksa kural
  /// sessizce etkisiz kalır (`catalog_snapshot_test.dart` denetler).
  static const unavailableTypes = <MarketId, Set<String>>{
    MarketId.bim: {
      'domates-1kg',
      'patates-1kg',
      'tavuk-1kg',
      'pilic-butun',
      'biber-1kg',
      'fasulye-1kg',
    },
    MarketId.hakmar: {
      'tavuk-1kg',
      'muz-1kg',
      'pilic-but',
      'filtre-kahve',
    },
    MarketId.tarimKredi: {
      'cips-150',
      'sampuan-400',
      'dondurma-500',
      'bebek-bezi',
      'dus-jeli',
    },
    MarketId.metro: {'ekmek-tam-bugday', 'ekmek-beyaz', 'maydanoz'},
    MarketId.getir: {'kofte-500', 'kiyma-400', 'un-5kg'},
    MarketId.file: {'kofte-500', 'sucuk-250'},
  };

  /// Çeşidi sınırlı, ağırlıklı olarak kendi markasını satan marketler.
  static const _limitedAssortment = <MarketId>{
    MarketId.bim,
    MarketId.a101,
    MarketId.sok,
    MarketId.hakmar,
    MarketId.tarimKredi,
  };

  /// Yalnızca geniş çeşitli marketlerde bulunan markalar.
  static const premiumOnlyBrands = <String>{
    'Barilla',
    'Danone',
    'Head & Shoulders',
    'Dove',
    'Doritos',
    "Kellogg's",
    'Mehmet Efendi',
  };

  @override
  Future<List<ProductType>> searchProductTypes(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return searchProductTypesLocal(query);
  }

  @override
  Future<ComparisonResult> compareBasket(List<ListItem> items) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();

    final baskets = Market.all.map((market) {
      final lines = items
          .map((item) => _line(market.id, item.product, item.quantity))
          .toList();

      return MarketBasketResult(
        market: market,
        lines: lines,
        fetchedAt: now,
        status: FetchStatus.ok,
      );
    }).toList();

    return ComparisonResult(
      baskets: baskets,
      comparedAt: now,
      source: PriceSource.mock,
    );
  }

  LinePrice _line(MarketId marketId, Product product, int quantity) {
    final brandRef = _brandRef(marketId, product);
    final indexed = marketPriceIndex[product.id]?.prices[marketId];
    final verifiedPrice =
        brandRef?.price ?? indexed ?? _typePrice(marketId, product);

    return LinePrice(
      product: product,
      quantity: quantity,
      unitPrice: verifiedPrice ?? _derivedPrice(marketId, product),
      available: _available(marketId, product, brandRef, indexed),
      verified: verifiedPrice != null,
      source: ProductSourceUrl.resolve(marketId: marketId, product: product),
    );
  }

  /// Bu market bu marka + birimi satıyor mu?
  ///
  /// Sırasıyla: marketin ürün sayfasındaki stok bilgisi, fiyat indeksindeki
  /// kayıt ve son olarak katalog varsayımları. İndekste kayıt bulunmaması
  /// "satılmıyor" demek değildir; indeks her zincirin tüm çeşidini
  /// kapsamadığı için eksiklik kanıt sayılmaz.
  bool _available(
    MarketId marketId,
    Product product,
    MarketProductRef? brandRef,
    double? indexed,
  ) {
    if (brandRef != null) return brandRef.inStock;
    if (indexed != null) return true;
    return _carries(marketId, product);
  }

  /// Bu market bu ürünün marka + birim eşleşmesini sitesinde yayınlıyor mu?
  static MarketProductRef? _brandRef(MarketId marketId, Product product) {
    final entry = marketProductSnapshot[product.id];
    if (entry == null) return null;
    return switch (marketId) {
      MarketId.sok => entry.sok,
      MarketId.happyCenter => entry.happyCenter,
      _ => null,
    };
  }

  /// Markasız / market markası satırın bağlandığı tip ürününün gerçek fiyatı.
  ///
  /// Satır o marketin ürün sayfasına gittiği için fiyat da aynı sayfadan
  /// okunur; aksi halde ekranda yazan tutar linkteki fiyattan farklı olurdu.
  static double? _typePrice(MarketId marketId, Product product) {
    if (!ProductSourceUrl.isGenericBrand(product.brand)) return null;
    final ref = marketPriceSnapshot[product.typeId];
    if (ref == null) return null;
    return switch (marketId) {
      MarketId.sok => ref.sokPath == null ? null : ref.sokPrice,
      MarketId.happyCenter =>
        ref.happyCenterPath == null ? null : ref.happyCenterPrice,
      _ => null,
    };
  }

  bool _carries(MarketId marketId, Product product) {
    final missingTypes = unavailableTypes[marketId] ?? const <String>{};
    if (missingTypes.contains(product.typeId)) return false;
    return !_brandMissing(marketId, product.brand);
  }

  double _derivedPrice(MarketId marketId, Product product) {
    final index = _marketIndex[marketId] ?? 1.0;
    final jitter = _productJitter(marketId, product.typeId);
    return _roundMoney(_referencePrice(product) * index * jitter);
  }

  /// Ürünün market seviyesinden bağımsız referans fiyatı.
  ///
  /// Markanın doğrulanmış fiyatları varsa onların ortalaması kullanılır;
  /// böylece "Sütaş Kaşar 500g" ile "Mis Kaşar 500g" gerçek fiyat farkını
  /// indeksin kapsamadığı marketlerde de korur.
  static double _referencePrice(Product product) {
    final verified = <double>[
      ...?marketProductSnapshot[product.id]?.all.map((ref) => ref.price),
      ...?marketPriceIndex[product.id]?.prices.values,
    ];
    if (verified.isNotEmpty) {
      return verified.reduce((a, b) => a + b) / verified.length;
    }
    final typeRef = marketPriceSnapshot[product.typeId];
    if (typeRef == null) return 49.90;
    return typeRef.unitPrice * _brandFactor(product.brand);
  }

  bool _brandMissing(MarketId marketId, String? brand) {
    if (brand == null || brand.isEmpty) return false;
    return _limitedAssortment.contains(marketId) &&
        premiumOnlyBrands.contains(brand);
  }

  /// Ürün bazlı ±4% deterministik sapma — her market farklı üründe öne çıkar.
  double _productJitter(MarketId marketId, String typeId) {
    final seed = '${marketId.name}:$typeId'.hashCode.abs();
    return 0.96 + (seed % 9) * 0.01;
  }

  /// Doğrulanmış fiyatı olmayan markalar için segment farkı.
  static double _brandFactor(String? brand) {
    if (brand == null || brand.isEmpty) return 0.97;
    if (brand == 'Market markası') return 0.88;
    if (premiumOnlyBrands.contains(brand)) return 1.12;
    final h = brand.hashCode.abs() % 9;
    return 0.96 + (h * 0.01);
  }

  static double _roundMoney(double value) =>
      (value * 100).roundToDouble() / 100;
}
