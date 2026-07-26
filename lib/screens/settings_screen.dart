import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Uygulama ve fiyat kaynağı tercihleri',
              style: TextStyle(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
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
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Canlı fiyat için --dart-define=USE_LIVE_PRICES=true '
                've API_BASE_URL ile çalıştırın.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: AppColors.greenDark,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.inkMuted,
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
