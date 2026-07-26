import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/basket_controller.dart';
import '../theme/app_theme.dart';
import 'basket_screen.dart';
import 'compare_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  void goTo(int index) {
    if (index < 0 || index > 3) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final basket = context.watch<BasketController>();

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenTab: goTo),
          BasketScreen(onOpenCompareTab: () => goTo(2)),
          const CompareScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: goTo,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.greenSoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Anasayfa',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: basket.totalQuantity > 0,
              label: Text('${basket.totalQuantity}'),
              child: const Icon(Icons.shopping_basket_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: basket.totalQuantity > 0,
              label: Text('${basket.totalQuantity}'),
              child: const Icon(Icons.shopping_basket_rounded),
            ),
            label: 'Sepet',
          ),
          const NavigationDestination(
            icon: Icon(Icons.compare_arrows_outlined),
            selectedIcon: Icon(Icons.compare_arrows_rounded),
            label: 'Karşılaştır',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
