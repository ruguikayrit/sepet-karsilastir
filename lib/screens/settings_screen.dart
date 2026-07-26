import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/market.dart';
import '../state/settings_controller.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final settings = context.watch<SettingsController>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              'Ayarlar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Görünüm ve fiyat kaynağı tercihleri',
              style: TextStyle(
                color: palette.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Görünüm',
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SegmentedButton<ThemeMode>(
                    segments: ThemeMode.values
                        .map(
                          (mode) => ButtonSegment(
                            value: mode,
                            label: Text(mode.label),
                            icon: Icon(mode.icon, size: 18),
                          ),
                        )
                        .toList(),
                    selected: {settings.themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        settings.setThemeMode(selection.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Fiyat kaynağı',
              children: [
                _InfoRow(
                  label: 'Mod',
                  value: AppConfig.useLivePrices ? 'Canlı' : 'Demo',
                ),
                _InfoRow(
                  label: 'API',
                  value: AppConfig.apiBaseUrl,
                ),
                _InfoRow(
                  label: 'Bölge',
                  value: AppConfig.defaultRegion,
                ),
                _InfoRow(
                  label: 'Market',
                  value: '${Market.all.length} zincir',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Hakkında',
              children: const [
                _InfoRow(label: 'Uygulama', value: 'Sepet (geçici ad)'),
                _InfoRow(label: 'Sürüm', value: '1.0.0'),
                _InfoRow(
                  label: 'Amaç',
                  value: 'Market sepeti fiyat karşılaştırması',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.greenSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                AppConfig.useLivePrices
                    ? 'Canlı fiyat modu açık. Backend yanıt vermezse kısmi '
                        'sonuçlar gösterilir.'
                    : 'Şu an demo fiyatlar kullanılıyor. Canlı fiyat için '
                        '--dart-define=USE_LIVE_PRICES=true ve API_BASE_URL '
                        'ile çalıştırın.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: palette.onGreenSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: TextStyle(
                color: palette.inkMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
