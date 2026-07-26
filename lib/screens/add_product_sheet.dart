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
  List<ProductType> _results = const [];
  bool _loading = true;
  String? _selectedBrand;

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

  Future<void> _addType(ProductType type) async {
    final basket = context.read<BasketController>();
    String? brand = _selectedBrand;

    if (brand == null) {
      brand = await _pickBrand(type);
      if (brand == null || !mounted) return;
    }

    final product = type.withBrand(brand);
    basket.addProduct(product);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.displayName} eklendi'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Future<String?> _pickBrand(ProductType type) {
    final brands = brandsForCategory(type.category);
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  '${type.name} için marka seç',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  itemCount: brands.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, index) {
                    final brand = brands[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: AppColors.cream,
                      title: Text(
                        brand.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pop(ctx, brand.name),
                    );
                  },
                ),
              ),
            ],
          ),
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
            child: Text(
              'Marka filtresi',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: brands.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final selected = _selectedBrand == null;
                  return FilterChip(
                    label: const Text('Tümü'),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedBrand = null),
                    selectedColor: AppColors.greenSoft,
                    checkmarkColor: AppColors.greenDark,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.greenDark : AppColors.ink,
                    ),
                  );
                }
                final brand = brands[index - 1];
                final selected = _selectedBrand == brand.name;
                return FilterChip(
                  label: Text(brand.name),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedBrand = selected ? null : brand.name;
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
          if (_selectedBrand != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Seçili marka: $_selectedBrand — ürün ekleyince bu marka kullanılır',
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
                          final preview = type.withBrand(_selectedBrand);
                          final inList = basket.items
                              .any((i) => i.product.id == preview.id);
                          final brandHint = _selectedBrand ??
                              'Marka seçilecek';
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            tileColor: AppColors.cream,
                            title: Text(
                              type.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '$brandHint · ${type.category} · ${type.unit}',
                              style: const TextStyle(color: AppColors.inkMuted),
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: () => _addType(type),
                              style: FilledButton.styleFrom(
                                backgroundColor: inList
                                    ? AppColors.greenSoft
                                    : AppColors.orangeSoft,
                                foregroundColor: inList
                                    ? AppColors.greenDark
                                    : AppColors.orange,
                              ),
                              child: Text(
                                _selectedBrand == null
                                    ? 'Marka seç'
                                    : (inList ? '+1' : 'Ekle'),
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
