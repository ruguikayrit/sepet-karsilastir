import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_shell.dart';
import 'services/price_service.dart';
import 'services/storage/basket_repository.dart';
import 'services/storage/key_value_store.dart';
import 'state/basket_controller.dart';
import 'state/settings_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await PreferencesStore.open();
  runApp(SepetApp(store: store));
}

class SepetApp extends StatelessWidget {
  const SepetApp({super.key, this.store});

  /// Kalıcı depo. Testlerde verilmezse bellek içi depo kullanılır.
  final KeyValueStore? store;

  @override
  Widget build(BuildContext context) {
    final resolvedStore = store ?? InMemoryStore();

    return MultiProvider(
      providers: [
        Provider<PriceService>(create: (_) => createPriceService()),
        ChangeNotifierProvider(
          create: (_) => SettingsController(resolvedStore),
        ),
        ChangeNotifierProvider(
          create: (context) => BasketController(
            context.read<PriceService>(),
            repository: BasketRepository(resolvedStore),
          ),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Sepet',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
