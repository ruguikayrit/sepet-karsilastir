import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/basket_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/quantity_stepper.dart';
import 'add_product_sheet.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key, required this.onOpenCompareTab});

  final VoidCallback onOpenCompareTab;

  @override
  Widget build(BuildContext context) {
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
                              ? 'Ürün ekleyerek listeyi oluştur'
                              : '${basket.totalQuantity} ürün listede',
                          style: const TextStyle(
                            color: AppColors.inkMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!basket.isEmpty)
                    TextButton(
                      onPressed: basket.clear,
                      child: const Text('Temizle'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.orangeSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        basket.isEmpty
                            ? 'Ürün ekle, 5 marketten en düşük toplamı anında gör.'
                            : 'Hazır olduğunda Karşılaştır sekmesine geç.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: basket.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: basket.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = basket.items[index];
                        return Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.greenSoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: AppColors.greenDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      style: const TextStyle(
                                        color: AppColors.inkMuted,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
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
                                onPressed: () =>
                                    basket.removeProduct(item.product.id),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    onOpenCompareTab();
                  },
            child: basket.comparing
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    basket.isEmpty
                        ? 'Önce ürün ekleyin'
                        : 'Marketleri karşılaştır',
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.playlist_add_rounded,
                size: 44,
                color: AppColors.green,
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
            const Text(
              'Alışveriş listeni oluştur.\nMigros, A101, Şok, Carrefour ve File\nfiyatlarını tek bakışta karşılaştır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.inkMuted,
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
