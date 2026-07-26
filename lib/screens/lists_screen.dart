import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comparison_result.dart';
import '../models/comparison_snapshot.dart';
import '../models/saved_list.dart';
import '../state/basket_controller.dart';
import '../theme/app_theme.dart';
import '../utils/dates.dart';
import '../utils/money.dart';
import '../widgets/market_badge.dart';
import '../widgets/name_prompt_dialog.dart';

enum _ListsTab { saved, history }

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  _ListsTab _tab = _ListsTab.saved;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final basket = context.watch<BasketController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Listelerim',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Kayıtlı listeler ve geçmiş karşılaştırmalar',
                    style: TextStyle(
                      color: palette.inkMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: SegmentedButton<_ListsTab>(
                segments: [
                  ButtonSegment(
                    value: _ListsTab.saved,
                    label: Text('Listeler (${basket.savedLists.length})'),
                    icon: const Icon(Icons.bookmark_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: _ListsTab.history,
                    label: Text('Geçmiş (${basket.history.length})'),
                    icon: const Icon(Icons.history_rounded, size: 18),
                  ),
                ],
                selected: {_tab},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    setState(() => _tab = selection.first),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _tab == _ListsTab.saved
                    ? _SavedListsView(
                        key: const ValueKey('saved'),
                        onOpenTab: widget.onOpenTab,
                      )
                    : _HistoryView(
                        key: const ValueKey('history'),
                        onOpenTab: widget.onOpenTab,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedListsView extends StatelessWidget {
  const _SavedListsView({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final basket = context.watch<BasketController>();
    final lists = basket.savedLists;

    if (lists.isEmpty) {
      return _EmptyView(
        icon: Icons.bookmark_border_rounded,
        title: 'Henüz kayıtlı liste yok',
        body: basket.isEmpty
            ? 'Sepetini oluşturduktan sonra buraya kaydedip\nher hafta tek dokunuşla geri yükleyebilirsin.'
            : 'Şu anki sepetini kaydet, sonraki alışverişte\ntek dokunuşla geri yükle.',
        actionLabel: basket.isEmpty ? 'Sepete ürün ekle' : 'Sepeti kaydet',
        onAction: () {
          if (basket.isEmpty) {
            onOpenTab(1);
          } else {
            _saveCurrentBasket(context);
          }
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        if (!basket.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed: () => _saveCurrentBasket(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Mevcut sepeti kaydet (${basket.totalQuantity} ürün)',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                side: BorderSide(color: context.palette.border),
                foregroundColor: context.palette.onGreenSoft,
              ),
            ),
          ),
        ...lists.map(
          (list) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SavedListCard(list: list, onOpenTab: onOpenTab),
          ),
        ),
      ],
    );
  }
}

Future<void> _saveCurrentBasket(BuildContext context) async {
  final controller = context.read<BasketController>();
  final messenger = ScaffoldMessenger.of(context);

  final name = await showNamePromptDialog(
    context,
    title: 'Sepeti kaydet',
    confirmLabel: 'Kaydet',
  );
  if (name == null) return;

  final saved = controller.saveCurrentBasket(name);
  if (saved == null) return;
  messenger.showSnackBar(
    SnackBar(content: Text('“${saved.name}” kaydedildi')),
  );
}

class _SavedListCard extends StatelessWidget {
  const _SavedListCard({required this.list, required this.onOpenTab});

  final SavedList list;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final preview =
        list.items.take(3).map((i) => i.product.displayName).join(' · ');

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _load(context, merge: false),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
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
                  Icons.bookmark_rounded,
                  color: palette.onGreenSoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${list.totalQuantity} ürün · ${relativeTimeTr(list.updatedAt)}',
                      style: TextStyle(
                        color: palette.inkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.inkMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: palette.inkMuted),
                onSelected: (value) => switch (value) {
                  'replace' => _load(context, merge: false),
                  'merge' => _load(context, merge: true),
                  'rename' => _rename(context),
                  'delete' => _delete(context),
                  _ => null,
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'replace',
                    child: Text('Sepete yükle'),
                  ),
                  PopupMenuItem(
                    value: 'merge',
                    child: Text('Sepete ekle'),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: Text('Yeniden adlandır'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Sil'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _load(BuildContext context, {required bool merge}) {
    context.read<BasketController>().loadSavedList(list.id, merge: merge);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          merge ? '“${list.name}” sepete eklendi' : '“${list.name}” yüklendi',
        ),
      ),
    );
    onOpenTab(1);
  }

  Future<void> _rename(BuildContext context) async {
    final controller = context.read<BasketController>();
    final name = await showNamePromptDialog(
      context,
      title: 'Listeyi yeniden adlandır',
      confirmLabel: 'Kaydet',
      initialValue: list.name,
    );
    if (name == null) return;
    controller.renameSavedList(list.id, name);
  }

  Future<void> _delete(BuildContext context) async {
    final controller = context.read<BasketController>();
    final confirmed = await _confirm(
      context,
      title: 'Liste silinsin mi?',
      body: '“${list.name}” kalıcı olarak silinecek.',
    );
    if (confirmed) controller.deleteSavedList(list.id);
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final basket = context.watch<BasketController>();
    final history = basket.history;

    if (history.isEmpty) {
      return _EmptyView(
        icon: Icons.history_rounded,
        title: 'Geçmiş boş',
        body: 'Her karşılaştırma otomatik kaydedilir.\n'
            'Sonuçları burada tekrar görebilirsin.',
        actionLabel: basket.isEmpty ? 'Sepete ürün ekle' : 'Karşılaştır',
        onAction: () => onOpenTab(basket.isEmpty ? 1 : 2),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () async {
              final controller = context.read<BasketController>();
              final confirmed = await _confirm(
                context,
                title: 'Geçmiş temizlensin mi?',
                body: 'Tüm karşılaştırma kayıtları silinecek.',
              );
              if (confirmed) controller.clearHistory();
            },
            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
            label: const Text('Geçmişi temizle'),
          ),
        ),
        ...history.map(
          (snapshot) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SnapshotCard(snapshot: snapshot, onOpenTab: onOpenTab),
          ),
        ),
      ],
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.snapshot, required this.onOpenTab});

  final ComparisonSnapshot snapshot;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final winner = snapshot.winnerMarket;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      relativeTimeTr(snapshot.comparedAt),
                      style: TextStyle(
                        color: palette.inkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      winner == null
                          ? 'Tam sepet bulunamadı'
                          : '${winner.name} · ${formatTry(snapshot.winnerTotal ?? 0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitle(),
                      style: TextStyle(
                        color: snapshot.savings != null && snapshot.savings! > 0
                            ? palette.best
                            : palette.inkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (winner != null) MarketBadge(market: winner, compact: true),
            ],
          ),
          children: [
            ...snapshot.marketTotals.take(5).map(
                  (total) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            total.market.name,
                            style: TextStyle(
                              color: total.isComplete
                                  ? palette.ink
                                  : palette.inkMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (!total.isComplete)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '${total.missingCount} eksik',
                              style: TextStyle(
                                color: palette.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Text(
                          formatTry(total.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _restore(context),
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const Text('Sepete yükle'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      side: BorderSide(color: palette.border),
                      foregroundColor: palette.onGreenSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _delete(context),
                  tooltip: 'Kaydı sil',
                  icon: Icon(Icons.delete_outline_rounded,
                      color: palette.inkMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[
      '${snapshot.totalQuantity} ürün',
      '${snapshot.marketTotals.length} market',
    ];
    final savings = snapshot.savings;
    if (savings != null && savings > 0) {
      parts.add('${formatTry(savings)} fark');
    }
    if (snapshot.source == PriceSource.mock) parts.add('Demo');
    return parts.join(' · ');
  }

  void _restore(BuildContext context) {
    context.read<BasketController>().restoreSnapshot(snapshot.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sepet geçmişten yüklendi')),
    );
    onOpenTab(1);
  }

  Future<void> _delete(BuildContext context) async {
    final controller = context.read<BasketController>();
    final confirmed = await _confirm(
      context,
      title: 'Kayıt silinsin mi?',
      body: 'Bu karşılaştırma geçmişten kaldırılacak.',
    );
    if (confirmed) controller.deleteSnapshot(snapshot.id);
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

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
                color: palette.greenSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 44, color: palette.green),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.inkMuted,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: context.palette.danger,
          ),
          child: const Text('Sil'),
        ),
      ],
    ),
  );
  return result ?? false;
}
