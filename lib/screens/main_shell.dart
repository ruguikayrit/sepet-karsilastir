import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/basket_controller.dart';
import 'basket_screen.dart';
import 'compare_screen.dart';
import 'home_screen.dart';
import 'lists_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  static const _tabCount = 5;

  int _index = 0;

  void goTo(int index) {
    if (index < 0 || index >= _tabCount) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final basket = context.watch<BasketController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onOpenTab: goTo),
            BasketScreen(onOpenCompareTab: () => goTo(2)),
            const CompareScreen(),
            ListsScreen(onOpenTab: goTo),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: goTo,
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
              icon: Icon(Icons.place_outlined),
              selectedIcon: Icon(Icons.place_rounded),
              label: 'Sonuç',
            ),
            const NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'Listeler',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Ayarlar',
            ),
          ],
        ),
      ),
    );
  }
}
