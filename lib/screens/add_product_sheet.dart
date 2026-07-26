import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/brands.dart';
import '../data/mock_catalog.dart';
import '../state/basket_controller.dart';
import '../theme/app_theme.dart';

Future<void> showAddProductSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<BasketController>(),
      child: const AddProductSheet(),
    ),
  );
}

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

  /// Arama sonucundaki kategorilerde geçerli markalar.
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

  /// Bir ürün tipi için seçili filtrelerden uygun olanlar.
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
      basket.addProduct(type.withBrand(brand));
    }

    if (!mounted) return;
    final label = brands.length == 1
        ? '${brands.first} ${type.name} eklendi'
        : '${type.name} · ${brands.length} marka eklendi';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  Future<List<String>?> _pickBrands(ProductType type) {
    final brands = brandsForCategory(type.category);
    final chosen = <String>{};

    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
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
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text(
                      '${type.name} için marka seç',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      'Birden fazla marka seçebilirsin; her biri sepete ayrı satır olarak eklenir.',
                      style: TextStyle(
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      itemCount: brands.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, index) {
                        final brand = brands[index];
                        final selected = chosen.contains(brand.name);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (_) {
                            setSheetState(() {
                              if (selected) {
                                chosen.remove(brand.name);
                              } else {
                                chosen.add(brand.name);
                              }
                            });
                          },
                          activeColor: AppColors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: AppColors.cream,
                          title: Text(
                            brand.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: FilledButton(
                      onPressed: chosen.isEmpty
                          ? null
                          : () => Navigator.pop(ctx, chosen.toList()..sort()),
                      child: Text(
                        chosen.isEmpty
                            ? 'Marka seç'
                            : 'Sepete ekle (${chosen.length})',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.9;
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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              'Ürün ekle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _search,
              decoration: const InputDecoration(
                hintText: 'Süt, yumurta, deterjan…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
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
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedBrands.length} seçili',
                      style: const TextStyle(
                        color: AppColors.greenDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const Spacer(),
                if (_selectedBrands.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(_selectedBrands.clear),
                    child: const Text('Temizle'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
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
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedBrands.remove(brand.name);
                      } else {
                        _selectedBrands.add(brand.name);
                      }
                    });
                  },
                  selectedColor: AppColors.greenSoft,
                  checkmarkColor: AppColors.greenDark,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.greenDark : AppColors.ink,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              _selectedBrands.isEmpty
                  ? 'Marka seçmeden eklersen ürün başına marka sorulur.'
                  : 'Seçili markalar her ürüne ayrı satır olarak eklenir.',
              style: const TextStyle(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(
                        child: Text(
                          'Ürün bulunamadı',
                          style: TextStyle(
                            color: AppColors.inkMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final type = _results[index];
                          final applicable = _applicableBrands(type);
                          final inBasket = basket.items.where(
                            (i) => i.product.typeId == type.id,
                          );
                          final inBasketCount = inBasket.length;

                          final subtitle = applicable.isEmpty
                              ? '${type.category} · ${type.unit}'
                              : '${applicable.join(", ")} · ${type.unit}';

                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            tileColor: AppColors.cream,
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    type.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
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
                                      color: AppColors.greenSoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$inBasketCount',
                                      style: const TextStyle(
                                        color: AppColors.greenDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.inkMuted),
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: () => _addType(type),
                              style: FilledButton.styleFrom(
                                backgroundColor: applicable.isEmpty
                                    ? AppColors.orangeSoft
                                    : AppColors.greenSoft,
                                foregroundColor: applicable.isEmpty
                                    ? AppColors.orange
                                    : AppColors.greenDark,
                              ),
                              child: Text(
                                applicable.isEmpty
                                    ? 'Marka seç'
                                    : 'Ekle (${applicable.length})',
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
