import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/market.dart';
import '../state/basket_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';
import '../widgets/market_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final basket = context.watch<BasketController>();
    final result = basket.lastResult;
    final winner = result?.cheapestComplete;
    final savings = result?.savingsVsMostExpensive;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: palette.green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.shopping_basket_rounded,
                    color: palette.onAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sepet',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Hangi markete gideceğini bil',
                        style: TextStyle(
                          color: palette.inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: winner != null && savings != null && savings > 0
                  ? _SavingsHero(
                      key: const ValueKey('savings'),
                      marketName: winner.market.name,
                      total: winner.total,
                      savings: savings,
                      onTap: () => onOpenTab(2),
                    )
                  : !basket.isEmpty
                      ? _ActionHero(
                          key: const ValueKey('ready'),
                          title: 'Listen hazır — tek marketi bul',
                          body:
                              '${basket.totalQuantity} ürün kaydı. '
                              'Bugünün fiyatlarıyla hangi marketten '
                              'alırsan en az ödeyeceğini şimdi gör.',
                          cta: 'En ucuz marketi göster',
                          onTap: () => onOpenTab(2),
                        )
                      : _ActionHero(
                          key: const ValueKey('empty'),
                          title: 'Listeni yaz, tek marketi seç',
                          body:
                              'Aynı ürün bir markette yarısı fiyatına olabilir. '
                              'Listeyi kaydet; ${Market.all.length} marketin '
                              'bugünkü toplamını karşılaştırıp nereye '
                              'gideceğini söyleyelim.',
                          cta: 'Alışveriş listemi oluştur',
                          onTap: () => onOpenTab(1),
                        ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Sepette',
                    value: '${basket.totalQuantity}',
                    hint: basket.isEmpty ? 'ürün yok' : 'ürün',
                    onTap: () => onOpenTab(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Marka',
                    value: basket.isEmpty ? '—' : '${basket.uniqueBrandCount}',
                    hint: 'çeşit',
                    onTap: () => onOpenTab(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Tasarruf',
                    value: savings == null || savings <= 0
                        ? '—'
                        : formatTry(savings),
                    hint: winner == null ? 'henüz yok' : winner.market.shortName,
                    onTap: () => onOpenTab(2),
                  ),
                ),
              ],
            ),
            if (!basket.isEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Sepet özeti',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => onOpenTab(1),
                    child: const Text('Düzenle'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...basket.items.take(4).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    item.product.brand ?? 'Markasız',
                                    style: TextStyle(
                                      color: palette.inkMuted,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '×${item.quantity}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: palette.onGreenSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              if (basket.items.length > 4)
                Text(
                  '+${basket.items.length - 4} ürün daha',
                  style: TextStyle(
                    color: palette.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
            const SizedBox(height: 20),
            Text(
              'Neden tek marketi bulmak zor?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            const _InsightCard(
              icon: Icons.percent_rounded,
              title: 'Aynı ürün, çok farklı fiyat',
              body:
                  'Bir ürün bir markette yüzde 50 indirimliyken diğerinde '
                  'normal fiyatta olabilir. Raf farkı alışverişten alışverişe '
                  'değişir.',
            ),
            const SizedBox(height: 8),
            const _InsightCard(
              icon: Icons.timer_outlined,
              title: 'Tek tek bakmaya zaman yok',
              body:
                  'Çoklu market alışverişinde her ürüne ayrı ayrı bakmak '
                  'gerçekçi değil. Hangi marketten alırsan en az ödeyeceğini '
                  'bilmek zorlaşıyor.',
            ),
            const SizedBox(height: 8),
            const _InsightCard(
              icon: Icons.place_rounded,
              title: 'Biz tek adresi söylüyoruz',
              body:
                  'Listeni kaydet; güncel fiyatları toplayıp listenin tamamı '
                  'için en düşük toplamı veren marketi gösterelim. Sen de '
                  'doğrudan oraya git.',
            ),
            const SizedBox(height: 20),
            Text(
              'Bugün baktığımız ${Market.all.length} market',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Her tutar marketin kendi ürün sayfasından okunur. Okunamayan '
              'satırda tahmin yok; “ürün bulunamadı” yazar. Amaç: hangi tek '
              'markete gideceğini güvenle seçmek.',
              style: TextStyle(
                color: palette.inkMuted,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            ...MarketSegment.values.map((segment) {
              final markets = Market.bySegment(segment);
              if (markets.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.label,
                      style: TextStyle(
                        color: palette.inkMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          markets.map((m) => MarketBadge(market: m)).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SavingsHero extends StatelessWidget {
  const _SavingsHero({
    super.key,
    required this.marketName,
    required this.total,
    required this.savings,
    required this.onTap,
  });

  final String marketName;
  final double total;
  final double savings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: palette.accentGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bugün buraya git',
                style: TextStyle(
                  color: palette.onAccent.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$marketName · ${formatTry(savings)} kazanç',
                style: TextStyle(
                  color: palette.onAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Listenin en düşük toplamı ${formatTry(total)} — tek market yeterli',
                style: TextStyle(
                  color: palette.onAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionHero extends StatelessWidget {
  const _ActionHero({
    super.key,
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });

  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: palette.accentGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: palette.onAccent,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: palette.onAccent.withValues(alpha: 0.92),
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: palette.onAccent,
              foregroundColor: palette.greenDeep,
              minimumSize: const Size(160, 46),
            ),
            child: Text(cta),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final String value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: palette.inkMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.inkMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.orangeSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: palette.orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    color: palette.inkMuted,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
