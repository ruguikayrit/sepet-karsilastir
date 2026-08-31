import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/market.dart';
import '../services/price_book_service.dart';
import '../state/basket_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/name_prompt_dialog.dart';
import '../widgets/quantity_stepper.dart';
import 'add_product_sheet.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key, required this.onOpenCompareTab});

  final VoidCallback onOpenCompareTab;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final basket = context.watch<BasketController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
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
                          basket.isEmpty
                              ? 'Bugün hangi markete gideceğini bulmak için listeyi yaz'
                              : '${basket.totalQuantity} ürün — en ucuz tek marketi bulmaya hazır',
                          style: TextStyle(
                            color: palette.inkMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!basket.isEmpty) ...[
                    TextButton(
                      onPressed: () => _saveBasket(context),
                      child: const Text('Kaydet'),
                    ),
                    TextButton(
                      onPressed: basket.clear,
                      child: const Text('Temizle'),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.orangeSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: palette.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        basket.isEmpty
                            ? 'Aynı ürün farklı marketlerde çok farklı fiyata '
                                'satılabiliyor. Listeni yaz; ${Market.all.length} '
                                'marketin bugünkü toplamından en düşüğü söyleyelim.'
                            : 'Hazır olunca en ucuz marketi bul — ya da listeni '
                                'kaydedip sonra tekrar kullan.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: palette.ink,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: basket.isEmpty
                    ? const _EmptyState(key: ValueKey('empty'))
                    : ListView.separated(
                        key: const ValueKey('list'),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        itemCount: basket.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = basket.items[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(
                              milliseconds: 220 + (index * 30).clamp(0, 180),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 12, 10, 12),
                              decoration: BoxDecoration(
                                color: palette.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: palette.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: palette.greenSoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: palette.onGreenSoft,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.product.brand == null
                                              ? item.product.category
                                              : '${item.product.brand} · ${item.product.category}',
                                          style: TextStyle(
                                            color: palette.inkMuted,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        // Fiyatı hiçbir markette yayınlanmayan
                                        // satır karşılaştırmada boş kalır;
                                        // kullanıcı bunu sepette görsün.
                                        if (PriceBookService.pricedMarketCount(
                                              item.product.id,
                                            ) ==
                                            0)
                                          Text(
                                            'Hiçbir markette fiyatı bulunamadı',
                                            style: TextStyle(
                                              color: palette.danger,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  QuantityStepper(
                                    value: item.quantity,
                                    onChanged: (q) => basket.setQuantity(
                                      item.product.id,
                                      q,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => basket
                                        .removeProduct(item.product.id),
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: palette.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddProductSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ürün ekle'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: basket.isEmpty || basket.comparing
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final controller = context.read<BasketController>();
                      final ok = await controller.compare();
                      if (!context.mounted) return;
                      if (ok == null) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              controller.error ?? 'Fiyatlar alınamadı.',
                            ),
                          ),
                        );
                        return;
                      }
                      onOpenCompareTab();
                    },
              child: basket.comparing
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: palette.onAccent,
                      ),
                    )
                  : Text(
                      basket.isEmpty
                          ? 'Önce listeye ürün ekleyin'
                          : 'En ucuz marketi bul',
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBasket(BuildContext context) async {
    final controller = context.read<BasketController>();
    final messenger = ScaffoldMessenger.of(context);
    final name = await showNamePromptDialog(
      context,
      title: 'Sepeti kaydet',
      confirmLabel: 'Kaydet',
    );
    if (name == null) return;
    final saved = controller.saveCurrentBasket(name);
    if (saved == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text('“${saved.name}” kaydedildi')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

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
                Icons.playlist_add_rounded,
                size: 44,
                color: palette.green,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Listen boş',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alışveriş listeni buraya yaz.\n'
              'Biz bugünün fiyatlarını toplayıp\n'
              'hangi tek markete gideceğini söyleyelim.',
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
