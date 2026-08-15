import 'dart:io';

import 'providers/official_provider.dart';
import 'providers/synthetic_provider.dart';
import 'providers/unconfigured_provider.dart';

/// `PRICE_MODE`:
/// - `synthetic` (varsayılan): yerel demo motoru — resmi uygulama fiyatı değil
/// - `official`: yalnızca yapılandırılmış resmi market adaptörleri
enum PriceMode { synthetic, official }

PriceMode resolvePriceMode() {
  final raw = (Platform.environment['PRICE_MODE'] ?? 'synthetic').toLowerCase();
  return raw == 'official' ? PriceMode.official : PriceMode.synthetic;
}

class QuoteService {
  QuoteService({
    PriceMode? mode,
    List<OfficialMarketProvider>? providers,
  })  : mode = mode ?? resolvePriceMode(),
        _providers = {
          for (final p in providers ??
              ((mode ?? resolvePriceMode()) == PriceMode.official
                  ? buildOfficialProviders()
                  : buildSyntheticProviders()))
            p.slug: p,
        };

  final PriceMode mode;
  final Map<String, OfficialMarketProvider> _providers;

  Iterable<OfficialMarketProvider> get providers => _providers.values;

  OfficialMarketProvider? providerFor(String slug) => _providers[slug];

  Future<Map<String, dynamic>> quoteMarket({
    required String slug,
    required List<Map<String, dynamic>> items,
    String? region,
    String? storeId,
  }) async {
    final provider = _providers[slug];
    if (provider == null) {
      return MarketQuoteResult.failed(
        marketId: slug,
        message: 'Bilinmeyen market slug: $slug',
      ).toJson();
    }

    final quoteItems = items.map(QuoteItem.fromJson).toList();
    final result = await provider.fetchQuotes(
      items: quoteItems,
      region: region,
      storeId: storeId,
    );
    return result.toJson();
  }

  Map<String, dynamic> healthPayload() {
    return {
      'status': 'ok',
      'service': 'sepet-backend',
      'version': '1.0.0',
      'priceMode': mode.name,
      'policy':
          'Resmi market uygulama API / partner feed. Scraping ve app reverse-engineering yok.',
      'markets': _providers.values
          .map(
            (p) => {
              'slug': p.slug,
              'name': p.displayName,
              'configured': p.isConfigured,
              'hint': p.configurationHint,
            },
          )
          .toList(),
      'time': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
