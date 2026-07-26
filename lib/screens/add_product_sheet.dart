import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/brands.dart';
import '../data/mock_catalog.dart';
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
  final Set<String> _selectedBrands = {};
  List<ProductType> _results = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search(''));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    final results = await context.read<BasketController>().searchTypes(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  List<FoodBrand> get _visibleBrands {
    final names = <String>{};
    final list = <FoodBrand>[];
    for (final type in _results) {
      for (final brand in brandsForCategory(type.category)) {
        if (names.add(brand.name)) list.add(brand);
      }
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  List<String> _applicableBrands(ProductType type) {
    final allowed = brandsForCategory(type.category).map((b) => b.name).toSet();
    return _selectedBrands.where(allowed.contains).toList()..sort();
  }

  Future<void> _addType(ProductType type) async {
    final basket = context.read<BasketController>();
    var brands = _applicableBrands(type);

    if (brands.isEmpty) {
      final picked = await _pickBrands(type);
      if (picked == null || picked.isEmpty || !mounted) return;
      brands = picked;
    }

    for (final brand in brands) {
      // "Markasız" bir marka değil: satır markasız kalır, her market kendi
      // uygun ürününü gösterir.
      basket.addProduct(
        type.withBrand(brand == genericBrand ? null : brand),
      );
    }

    if (!mounted) return;
    final label = brands.length == 1
        ? '${brands.first} ${type.name} eklendi'
        : '${type.name} · ${brands.length} marka eklendi';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  Future<List<String>?> _pickBrands(ProductType type) {
    final palette = context.palette;
    final brands = brandsForCategory(type.category);
    final chosen = <String>{};

    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final sheetPalette = ctx.palette;
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: sheetPalette.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 2),
                      child: Text(
                        type.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Text(
                        'Bir veya birden fazla marka seç; her biri sepete ayrı satır olarak eklenir.',
                        style: TextStyle(
                          color: sheetPalette.inkMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        itemCount: brands.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, index) {
                          final brand = brands[index];
                          final selected = chosen.contains(brand.name);
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setSheetState(() {
                                selected
                                    ? chosen.remove(brand.name)
                                    : chosen.add(brand.name);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? sheetPalette.greenSoft
                                    : sheetPalette.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? sheetPalette.green
                                      : sheetPalette.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      brand.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    selected
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: selected
                                        ? sheetPalette.green
                                        : sheetPalette.border,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: chosen.isEmpty
                              ? null
                              : () =>
                                  Navigator.pop(ctx, chosen.toList()..sort()),
                          child: Text(
                            chosen.isEmpty
                                ? 'Marka seç'
                                : 'Sepete ekle (${chosen.length})',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final height = MediaQuery.sizeOf(context).height * 0.92;
    final basket = context.watch<BasketController>();
    final brands = _visibleBrands;

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
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Ürün ara: süt, yumurta, deterjan…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  size: 18,
                  color: palette.inkMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Marka filtresi',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(width: 8),
                if (_selectedBrands.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: palette.greenSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedBrands.length}',
                      style: TextStyle(
                        color: palette.onGreenSoft,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const Spacer(),
                if (_selectedBrands.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(_selectedBrands.clear),
                    child: Text(
                      'Temizle',
                      style: TextStyle(
                        color: palette.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: brands.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final brand = brands[index];
                final selected = _selectedBrands.contains(brand.name);
                return FilterChip(
                  label: Text(brand.name),
                  selected: selected,
                  showCheckmark: false,
                  avatar: selected
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: palette.onGreenSoft,
                        )
                      : null,
                  onSelected: (_) {
                    setState(() {
                      selected
                          ? _selectedBrands.remove(brand.name)
                          : _selectedBrands.add(brand.name);
                    });
                  },
                  visualDensity: VisualDensity.compact,
                  selectedColor: palette.greenSoft,
                  backgroundColor: palette.background,
                  side: BorderSide(
                    color: selected ? palette.green : palette.border,
                  ),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: selected ? palette.onGreenSoft : palette.ink,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _selectedBrands.isEmpty
                  ? 'Filtre seçmeden eklersen ürün başına marka sorulur.'
                  : 'Seçili markaların her biri ürüne ayrı satır olarak eklenir.',
              style: TextStyle(
                color: palette.inkMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const _NoResults()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final type = _results[index];
                          return _ProductRow(
                            type: type,
                            applicableBrands: _applicableBrands(type),
                            inBasketCount: basket.items
                                .where((i) => i.product.typeId == type.id)
                                .length,
                            onAdd: () => _addType(type),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.type,
    required this.applicableBrands,
    required this.inBasketCount,
    required this.onAdd,
  });

  final ProductType type;
  final List<String> applicableBrands;
  final int inBasketCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasFilter = applicableBrands.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
              categoryIcon(type.category),
              color: palette.onGreenSoft,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        type.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (inBasketCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: palette.greenSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$inBasketCount',
                          style: TextStyle(
                            color: palette.onGreenSoft,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  hasFilter
                      ? applicableBrands.join(', ')
                      : '${type.category} · ${type.unit}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        hasFilter ? palette.onGreenSoft : palette.inkMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
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
              backgroundColor:
                  hasFilter ? palette.green : palette.orangeSoft,
              foregroundColor:
                  hasFilter ? palette.onAccent : palette.orange,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: Text(
              hasFilter ? 'Ekle (${applicableBrands.length})' : 'Marka seç',
            ),
          ),
        ],
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
            'Farklı bir arama dene',
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
