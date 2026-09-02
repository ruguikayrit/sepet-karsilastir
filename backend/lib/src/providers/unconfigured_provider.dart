import 'dart:io';

import 'official_provider.dart';

/// Resmi API henüz bağlanmamış market adaptörü.
///
/// Ortam değişkenleri set edildiğinde [isConfigured] true olur; asıl HTTP
/// çağrısı marketin sağladığı dokümantasyona göre bu sınıfta veya alt
/// sınıfta uygulanır. Private app trafiğini dinlemek / taklit etmek yok.
class UnconfiguredOfficialProvider implements OfficialMarketProvider {
  UnconfiguredOfficialProvider({
    required this.slug,
    required this.displayName,
    required this.envPrefix,
    this.docsUrl,
  });

  @override
  final String slug;

  @override
  final String displayName;

  /// Örn. MIGROS → MIGROS_API_BASE, MIGROS_API_KEY
  final String envPrefix;
  final String? docsUrl;

  String get _base => Platform.environment['${envPrefix}_API_BASE'] ?? '';
  String get _key => Platform.environment['${envPrefix}_API_KEY'] ?? '';

  @override
  bool get isConfigured => _base.isNotEmpty && _key.isNotEmpty;

  @override
  String get configurationHint => isConfigured
      ? 'Yapılandırıldı ($_base) — resmi HTTP istemcisi henüz implemente edilmedi'
      : 'Resmi API yok. ${envPrefix}_API_BASE + ${envPrefix}_API_KEY gerekir.'
          '${docsUrl == null ? '' : ' Bkz. $docsUrl'}';

  @override
  Future<MarketQuoteResult> fetchQuotes({
    required List<QuoteItem> items,
    String? region,
    String? storeId,
  }) async {
    if (!isConfigured) {
      return MarketQuoteResult.failed(
        marketId: _marketId,
        message:
            '$displayName resmi fiyat API’si yapılandırılmadı. '
            'Market partner / developer erişimi olmadan uygulama fiyatı çekilmez.',
      );
    }

    // Kimlik bilgisi var ama entegrasyon henüz yazılmadı — sessizce
    // "başarılı sahte fiyat" üretmek yerine açıkça başarısız dön.
    return MarketQuoteResult.failed(
      marketId: _marketId,
      message:
          '$displayName için resmi API kimlik bilgisi bulundu ancak '
          'HTTP entegrasyonu henüz eklenmedi. Market dokümantasyonundaki '
          'endpoint’leri bu adaptöre bağlayın.',
    );
  }

  String get _marketId {
    const map = {
      'tarim-kredi': 'tarimKredi',
      'happy-center': 'happyCenter',
    };
    return map[slug] ?? slug;
  }
}

/// Tüm desteklenen marketlerin resmi adaptör kayıtları.
List<OfficialMarketProvider> buildOfficialProviders() {
  return [
    UnconfiguredOfficialProvider(
      slug: 'migros',
      displayName: 'Migros',
      envPrefix: 'MIGROS',
    ),
    UnconfiguredOfficialProvider(
      slug: 'macrocenter',
      displayName: 'Macrocenter',
      envPrefix: 'MACROCENTER',
    ),
    UnconfiguredOfficialProvider(
      slug: 'a101',
      displayName: 'A101',
      envPrefix: 'A101',
    ),
    UnconfiguredOfficialProvider(
      slug: 'bim',
      displayName: 'BİM',
      envPrefix: 'BIM',
    ),
    UnconfiguredOfficialProvider(
      slug: 'sok',
      displayName: 'Şok',
      envPrefix: 'SOK',
    ),
    UnconfiguredOfficialProvider(
      slug: 'carrefour',
      displayName: 'CarrefourSA',
      envPrefix: 'CARREFOUR',
    ),
    UnconfiguredOfficialProvider(
      slug: 'tarim-kredi',
      displayName: 'Tarım Kredi Market',
      envPrefix: 'TARIM_KREDI',
    ),
    UnconfiguredOfficialProvider(
      slug: 'hakmar',
      displayName: 'Hakmar Express',
      envPrefix: 'HAKMAR',
    ),
    UnconfiguredOfficialProvider(
      slug: 'happy-center',
      displayName: 'Happy Center',
      envPrefix: 'HAPPY_CENTER',
    ),
  ];
}
