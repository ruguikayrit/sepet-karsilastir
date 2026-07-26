import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/comparison_result.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/product_link.dart';
import '../services/price_book_service.dart';
import '../state/basket_controller.dart';
import '../theme/app_theme.dart';
import '../utils/dates.dart';
import '../utils/money.dart';
import '../widgets/market_badge.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final basket = context.watch<BasketController>();
    final result = basket.lastResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karşılaştırma'),
        actions: [
          if (result != null)
            IconButton(
              tooltip: 'Yenile',
              onPressed: basket.comparing
                  ? null
                  : () => context.read<BasketController>().compare(),
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: basket.comparing && result == null
            ? const _LoadingView(key: ValueKey('loading'))
            : result == null
                ? const _EmptyCompare(key: ValueKey('empty'))
                : _ResultBody(
                    key: const ValueKey('result'),
                    result: result,
                    refreshing: basket.comparing,
                  ),
      ),
    );
  }
}

class _EmptyCompare extends StatelessWidget {
  const _EmptyCompare({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: palette.greenSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.compare_arrows_rounded,
                size: 44,
                color: palette.green,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Henüz karşılaştırma yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sepete ürün ekleyip “Marketleri karşılaştır”\nbutonuna basarak sonucu burada gör.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.inkMuted,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 18),
          Text(
            'Marketlerden anlık fiyatlar alınıyor…',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '${PriceBookService.compared.length} market taranıyor',
            style: TextStyle(color: palette.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    super.key,
    required this.result,
    required this.refreshing,
  });

  final ComparisonResult result;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ranked = result.ranked;
    final winner = result.cheapestComplete;
    final savings = result.savingsVsMostExpensive;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            if (winner != null)
              _WinnerCard(winner: winner, savings: savings)
            else
              _NoCompleteBasketCard(result: result),
            const SizedBox(height: 18),
            Text(
              'Market sıralaması',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fiyatlar ${_priceDate(result)} · marketlerin kendi ürün '
              'sayfalarından · ${result.completeCount}/${result.baskets.length}'
              ' market listeyi tamamlıyor',
              style: TextStyle(color: palette.inkMuted, fontSize: 13),
            ),
            if (result.failedMarketCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${result.failedMarketCount} market yanıt vermedi',
                style: TextStyle(
                  color: palette.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...ranked.asMap().entries.map((entry) {
              final index = entry.key;
              final basket = entry.value;
              final isBest = winner != null &&
                  basket.market.id == winner.market.id &&
                  basket.isComplete;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MarketRankTile(
                  rank: index + 1,
                  basket: basket,
                  isBest: isBest,
                  delta: winner == null || !basket.isComplete
                      ? null
                      : basket.total - winner.total,
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'Ürün fiyat detayları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Her tutar, satıra dokununca açılan ürün sayfasındaki fiyattır; '
              'tıklayıp doğrulayabilirsin. Fiyatı yayınlanmayan satır boş '
              'kalır ve toplama eklenmez.',
              style: TextStyle(color: palette.inkMuted, fontSize: 13),
            ),
            const SizedBox(height: 10),
            ...ranked.map((b) => _MarketBreakdown(basket: b)),
            if (_absentMarkets.isNotEmpty) ...[
              const SizedBox(height: 8),
              const _UnpricedMarketsCard(),
            ],
          ],
        ),
        if (refreshing)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  static String _priceDate(ComparisonResult result) {
    final fetchedAt = result.pricesFetchedAt;
    final parsed = fetchedAt == null ? null : DateTime.tryParse(fetchedAt);
    if (parsed != null) return formatDateTr(parsed);
    return formatClock(result.comparedAt);
  }
}

/// Karşılaştırmaya girmeyen marketler ve sebepleri.
///
/// İki grup var: kendi sitesinde hiç ürün fiyatı yayınlamayanlar ve son
/// çekimde sitesi yanıt vermeyenler. İkisinde de uygulama tahmin üretmez.
Map<String, String> get _absentMarkets => {
      for (final market in Market.unpriced) market.name: market.noPriceReason!,
      for (final market in PriceBookService.missing)
        market.name: 'son çekimde sitesinden fiyat alınamadı',
    };

class _UnpricedMarketsCard extends StatelessWidget {
  const _UnpricedMarketsCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final markets = _absentMarkets;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Karşılaştırmaya girmeyen ${markets.length} market',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Fiyatı kendi sitesinden okunamayan market için tutar '
            'göstermiyoruz; tahmin yerine boş bırakıyoruz.',
            style: TextStyle(
              color: palette.inkMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          ...markets.entries.map(
            (market) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${market.key} — ${market.value}',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WinnerCard extends StatelessWidget {
  const _WinnerCard({required this.winner, required this.savings});

  final MarketBasketResult winner;
  final double? savings;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: palette.accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: palette.green.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: palette.onAccent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'EN KARLI',
                  style: TextStyle(
                    color: palette.onAccent,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              MarketBadge(market: winner.market),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            winner.market.name,
            style: TextStyle(
              color: palette.onAccent,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatTry(winner.total),
            style: TextStyle(
              color: palette.onAccent,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${winner.lines.length} satırın tamamı ${winner.market.name} '
            'ürün sayfalarından okundu',
            style: TextStyle(
              color: palette.onAccent.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (savings != null && savings! > 0) ...[
            const SizedBox(height: 10),
            Text(
              'En pahalı markete göre ${formatTry(savings!)} tasarruf',
              style: TextStyle(
                color: palette.onAccent.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Hiçbir market listeyi tamamlamıyorsa: neden ve nereye en yakın olduğunu anlatır.
class _NoCompleteBasketCard extends StatelessWidget {
  const _NoCompleteBasketCard({required this.result});

  final ComparisonResult result;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final closest = result.closestToComplete;
    final everywhere = result.productsMissingEverywhere;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.orangeSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.orange.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.report_gmailerrorred_rounded, color: palette.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Listeyi tek başına tamamlayan market yok',
                  style: TextStyle(
                    color: palette.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fiyatı eksik olan market “en ucuz” sayılmaz. Aşağıdaki toplamlar '
            'yalnızca o marketin sayfasından okunan ürünleri kapsar.',
            style: TextStyle(
              color: palette.ink,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (closest != null) ...[
            const SizedBox(height: 12),
            Text(
              'Listeye en yakın: ${closest.market.name} · '
              '${closest.availableCount}/${closest.lines.length} ürün '
              '(${formatTry(closest.total)})',
              style: TextStyle(
                color: palette.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Eksik: ${_names(closest.missingProducts)}',
              style: TextStyle(
                color: palette.inkMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          if (everywhere.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Hiçbir markette bulunamadı: ${_names(everywhere)}. '
              'Bu satırların markasını veya birimini değiştirmeyi dene.',
              style: TextStyle(
                color: palette.ink,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _names(List<Product> products) {
    final labels = products.map((p) => p.displayName).toList();
    if (labels.length <= 3) return labels.join(', ');
    return '${labels.take(3).join(', ')} +${labels.length - 3}';
  }
}

class _MarketRankTile extends StatelessWidget {
  const _MarketRankTile({
    required this.rank,
    required this.basket,
    required this.isBest,
    required this.delta,
  });

  final int rank;
  final MarketBasketResult basket;
  final bool isBest;
  final double? delta;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isBest ? palette.greenSoft : palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBest
              ? palette.green.withValues(alpha: 0.35)
              : palette.border,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isBest ? palette.green : palette.background,
            foregroundColor: isBest ? palette.onAccent : palette.inkMuted,
            child: Text(
              '$rank',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  basket.market.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  basket.fetchFailed
                      ? (basket.errorMessage ?? 'Fiyat alınamadı')
                      : basket.isComplete
                          ? '${basket.market.segment.label} · ${basket.availableCount} ürün tamam'
                          : '${basket.market.segment.label} · fiyatı yok: '
                              '${_NoCompleteBasketCard._names(basket.missingProducts)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: basket.fetchFailed || !basket.isComplete
                        ? palette.danger
                        : palette.inkMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                basket.fetchFailed ? '—' : formatTry(basket.total),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: isBest
                      ? palette.best
                      : basket.isPartial
                          ? palette.inkMuted
                          : palette.ink,
                ),
              ),
              if (basket.isPartial)
                Text(
                  'kısmi toplam',
                  style: TextStyle(
                    color: palette.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else if (!basket.fetchFailed && delta != null && delta! > 0)
                Text(
                  '+${formatTry(delta!)}',
                  style: TextStyle(
                    color: palette.inkMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarketBreakdown extends StatelessWidget {
  const _MarketBreakdown({required this.basket});

  final MarketBasketResult basket;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Row(
            children: [
              MarketBadge(market: basket.market, compact: true),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  basket.market.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatTry(basket.total),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (basket.isPartial)
                    Text(
                      '${basket.missingCount} ürünün fiyatı yok',
                      style: TextStyle(
                        color: palette.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    Text(
                      '${basket.lines.length} fiyat market sayfasından',
                      style: TextStyle(
                        color: palette.inkMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          children: basket.lines.map((line) {
            return _ProductPriceRow(line: line);
          }).toList(),
        ),
      ),
    );
  }
}

class _ProductPriceRow extends StatelessWidget {
  const _ProductPriceRow({required this.line});

  final LinePrice line;

  Future<void> _openSource(BuildContext context) async {
    final link = line.source;
    final messenger = ScaffoldMessenger.of(context);
    final uri = link == null ? null : Uri.tryParse(link.url);
    if (uri == null) return;
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw Exception('launch reddedildi');
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text('${uri.host} açılamadı')),
      );
    }
  }

  IconData get _icon => switch (line.source?.kind) {
        ProductLinkKind.product => Icons.open_in_new_rounded,
        ProductLinkKind.search => Icons.search_rounded,
        ProductLinkKind.site => Icons.storefront_outlined,
        null => Icons.open_in_new_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final link = line.source;
    final hasLink = link != null && link.url.isNotEmpty;
    final marketProduct = line.marketProduct;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasLink ? () => _openSource(context) : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${line.product.displayName} ×${line.quantity}',
                      style: TextStyle(
                        color: line.available ? palette.ink : palette.inkMuted,
                        decoration: line.available
                            ? TextDecoration.underline
                            : TextDecoration.lineThrough,
                        decorationColor: palette.ink.withValues(alpha: 0.35),
                      ),
                    ),
                    // Fiyatın okunduğu ürün: satıra dokununca bu ürün açılır.
                    if (marketProduct != null)
                      Text(
                        marketProduct,
                        style: TextStyle(
                          color: palette.inkMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasLink) ...[
                Tooltip(
                  message: '${link.kind.label} · ${link.host}',
                  child: Icon(_icon, size: 16, color: palette.inkMuted),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                line.available ? formatTry(line.lineTotal) : 'Fiyat yok',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: line.available ? palette.ink : palette.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
