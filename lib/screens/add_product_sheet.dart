import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/basket_controller.dart';
import '../theme/app_theme.dart';

Future<void> showAddProductSheet(BuildContext context) {
  final palette = context.palette;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<BasketController>(),
      child: const AddProductSheet(),
    ),
  );
}

IconData categoryIcon(String category) => switch (category) {
      'Süt & Kahvaltı' => Icons.egg_alt_outlined,
      'Fırın' => Icons.bakery_dining_outlined,
      'Temel Gıda' => Icons.rice_bowl_outlined,
      'Konserve' => Icons.inventory_outlined,
      'İçecek' => Icons.local_drink_outlined,
      'Meyve & Sebze' => Icons.eco_outlined,
      'Et & Tavuk' => Icons.set_meal_outlined,
      'Temizlik' => Icons.cleaning_services_outlined,
      'Kişisel Bakım' => Icons.spa_outlined,
      'Atıştırmalık' => Icons.cookie_outlined,
      'Dondurma' => Icons.icecream_outlined,
      'Bebek' => Icons.baby_changing_station_outlined,
      _ => Icons.inventory_2_outlined,
    };

class AddProductSheet extends StatefulWidget {
  const AddProductSheet({super.key});

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  final _controller = TextEditingController();
  List<Product> _liveProducts = const [];
  bool _loading = false;
  Timer? _debounce;
  int _searchGen = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 280), () => _search(query));
  }

  Future<void> _search(String query) async {
    final gen = ++_searchGen;
    final q = query.trim();
    if (q.length < 2) {
      if (!mounted || gen != _searchGen) return;
      setState(() {
        _liveProducts = const [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    final live =
        await context.read<BasketController>().searchCatalogProducts(q);
    if (!mounted || gen != _searchGen) return;
    setState(() {
      _liveProducts = live;
      _loading = false;
    });
  }

  void _addLiveProduct(Product product) {
    context.read<BasketController>().addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.brandLabel} · ${product.name}'
            '${product.sizeLabel == null ? '' : ' · ${product.sizeLabel}'}'
            ' eklendi'),
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final height = MediaQuery.sizeOf(context).height * 0.92;
    final basket = context.watch<BasketController>();
    final query = _controller.text.trim();

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: palette.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ürün ekle',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (basket.totalQuantity > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: palette.greenSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sepette ${basket.totalQuantity}',
                      style: TextStyle(
                        color: palette.onGreenSoft,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: palette.inkMuted,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Ürün adı yazın: süt, yağ, deterjan…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _debounce?.cancel();
                          _controller.clear();
                          _search('');
                        },
                      ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : query.length < 2
                    ? const _IdleHint()
                    : _liveProducts.isEmpty
                        ? const _NoResults()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                            itemCount: _liveProducts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final product = _liveProducts[index];
                              return _LiveProductRow(
                                product: product,
                                inBasket: basket.items.any(
                                  (i) => i.product.id == product.id,
                                ),
                                onAdd: () => _addLiveProduct(product),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _LiveProductRow extends StatelessWidget {
  const _LiveProductRow({
    required this.product,
    required this.inBasket,
    required this.onAdd,
  });

  final Product product;
  final bool inBasket;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final size = product.sizeLabel;

    return Semantics(
      button: true,
      label:
          '${product.brandLabel}, ${product.name}${size == null ? '' : ', $size'}',
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
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
                    categoryIcon(product.category),
                    color: palette.onGreenSoft,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brandLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.green,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if (size != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: palette.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: palette.border),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: palette.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.tonal(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(84, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: palette.green,
                    foregroundColor: palette.onAccent,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(inBasket ? 'Ekle +' : 'Ekle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdleHint extends StatelessWidget {
  const _IdleHint();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 34,
                color: palette.inkMuted,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ürün adı yazın',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Marka, ürün adı ve ebat canlı listede çıkar. '
              'İstediğiniz markayı ve gramajı seçin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.inkMuted,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 34,
              color: palette.inkMuted,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Ürün bulunamadı',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Farklı bir ürün adı deneyin',
            style: TextStyle(
              color: palette.inkMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
