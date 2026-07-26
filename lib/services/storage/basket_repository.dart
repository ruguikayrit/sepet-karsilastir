import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../models/comparison_snapshot.dart';
import '../../models/list_item.dart';
import '../../models/saved_list.dart';
import 'key_value_store.dart';

/// Sepet, kayıtlı listeler ve karşılaştırma geçmişinin kalıcı deposu.
///
/// Bozuk / eski formatlı kayıtlar sessizce atılır: kullanıcı hatalı bir
/// kayıt yüzünden açılmayan bir uygulamayla karşılaşmamalı.
class BasketRepository {
  BasketRepository(this._store);

  static const _basketKey = 'basket.items.v1';
  static const _savedListsKey = 'basket.savedLists.v1';
  static const _historyKey = 'basket.history.v1';

  /// Geçmişte tutulan en fazla karşılaştırma sayısı.
  static const historyLimit = 30;

  final KeyValueStore _store;

  List<ListItem> loadBasket() => _decodeList(_basketKey, ListItem.fromJson);

  Future<void> saveBasket(List<ListItem> items) =>
      _encodeList(_basketKey, items.map((e) => e.toJson()).toList());

  List<SavedList> loadSavedLists() {
    final lists = _decodeList(_savedListsKey, SavedList.fromJson);
    lists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return lists;
  }

  Future<void> saveSavedLists(List<SavedList> lists) =>
      _encodeList(_savedListsKey, lists.map((e) => e.toJson()).toList());

  List<ComparisonSnapshot> loadHistory() {
    final history = _decodeList(_historyKey, ComparisonSnapshot.fromJson);
    history.sort((a, b) => b.comparedAt.compareTo(a.comparedAt));
    return history;
  }

  Future<void> saveHistory(List<ComparisonSnapshot> history) {
    final capped = history.take(historyLimit).toList();
    return _encodeList(_historyKey, capped.map((e) => e.toJson()).toList());
  }

  Future<void> clearAll() async {
    await _store.remove(_basketKey);
    await _store.remove(_savedListsKey);
    await _store.remove(_historyKey);
  }

  List<T> _decodeList<T>(String key, T Function(Map<String, dynamic>) parse) {
    final raw = _store.read(key);
    if (raw == null || raw.isEmpty) return <T>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <T>[];
      final result = <T>[];
      for (final entry in decoded) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          result.add(parse(entry));
        } catch (e) {
          debugPrint('Bozuk kayıt atlandı ($key): $e');
        }
      }
      return result;
    } catch (e) {
      debugPrint('Kayıt okunamadı ($key): $e');
      return <T>[];
    }
  }

  Future<void> _encodeList(String key, List<Map<String, dynamic>> data) {
    if (data.isEmpty) return _store.remove(key);
    return _store.write(key, jsonEncode(data));
  }
}
