import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comparison_result.dart';
import '../models/market.dart';
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
            '${Market.all.length} market taranıyor',
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
            if (winner != null) _WinnerCard(winner: winner, savings: savings),
            const SizedBox(height: 18),
            Text(
              'Market sıralaması',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Güncellendi: ${formatClock(result.comparedAt)}'
              ' · ${result.source == PriceSource.live ? 'Canlı' : 'Demo'}',
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
              'Ürün kırılımı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            ...ranked.map((b) => _MarketBreakdown(basket: b)),
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
                          : '${basket.market.segment.label} · ${basket.missingCount} ürün yok',
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
                  color: isBest ? palette.best : palette.ink,
                ),
              ),
              if (!basket.fetchFailed && delta != null && delta! > 0)
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
              Text(
                formatTry(basket.total),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          children: basket.lines.map((line) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${line.product.displayName} ×${line.quantity}',
                      style: TextStyle(
                        color: line.available ? palette.ink : palette.inkMuted,
                        decoration: line.available
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  Text(
                    line.available ? formatTry(line.lineTotal) : 'Yok',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: line.available ? palette.ink : palette.danger,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
