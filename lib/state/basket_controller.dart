import 'package:flutter/foundation.dart';

import '../data/mock_catalog.dart';
import '../models/comparison_result.dart';
import '../models/comparison_snapshot.dart';
import '../models/list_item.dart';
import '../models/product.dart';
import '../models/saved_list.dart';
import '../services/hybrid_price_service.dart';
import '../services/price_service.dart';
import '../services/storage/basket_repository.dart';
import '../services/storage/key_value_store.dart';

class BasketController extends ChangeNotifier {
  BasketController(this._priceService, {BasketRepository? repository})
      : _repository = repository ?? BasketRepository(InMemoryStore()) {
    _restore();
  }

  final PriceService _priceService;
  final BasketRepository _repository;

  final List<ListItem> _items = [];
  List<SavedList> _savedLists = [];
  List<ComparisonSnapshot> _history = [];
  ComparisonResult? _lastResult;
  bool _comparing = false;
  String? _error;

  List<ListItem> get items => List.unmodifiable(_items);
  List<SavedList> get savedLists => List.unmodifiable(_savedLists);
  List<ComparisonSnapshot> get history => List.unmodifiable(_history);
  ComparisonResult? get lastResult => _lastResult;
  bool get comparing => _comparing;
  String? get error => _error;
  int get totalQuantity =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  int get uniqueBrandCount {
    final brands = <String>{};
    for (final item in _items) {
      final brand = item.product.brand;
      if (brand != null && brand.isNotEmpty) brands.add(brand);
    }
    return brands.length;
  }

  void _restore() {
    _items.addAll(_repository.loadBasket());
    _savedLists = _repository.loadSavedLists();
    _history = _repository.loadHistory();
  }

  void addProduct(Product product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    } else {
      _items.add(ListItem(product: product));
    }
    _lastResult = null;
    _error = null;
    _persistBasket();
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _lastResult = null;
    _persistBasket();
    notifyListeners();
  }

  void setQuantity(String productId, int quantity) {
    if (quantity < 1) {
      removeProduct(productId);
      return;
    }
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;
    _items[index] = _items[index].copyWith(quantity: quantity);
    _lastResult = null;
    _persistBasket();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _lastResult = null;
    _error = null;
    _persistBasket();
    notifyListeners();
  }

  Future<ComparisonResult?> compare() async {
    if (_items.isEmpty) return null;
    _comparing = true;
    _error = null;
    notifyListeners();
    try {
      final service = _priceService;
      if (service is HybridPriceService && service.canStreamLive) {
        ComparisonResult? finalResult;
        await for (final snapshot in service.watchBasketComparison(_items)) {
          _lastResult = snapshot;
          _comparing = snapshot.refreshing;
          finalResult = snapshot;
          notifyListeners();
        }
        if (finalResult != null) {
          _recordHistory(finalResult);
        }
        return finalResult;
      }

      final result = await _priceService.compareBasket(_items);
      _lastResult = result;
      _recordHistory(result);
      return result;
    } catch (e) {
      _error = 'Fiyatlar alınamadı. Tekrar deneyin.';
      return null;
    } finally {
      _comparing = false;
      notifyListeners();
    }
  }

  Future<List<ProductType>> searchTypes(String query) =>
      _priceService.searchProductTypes(query);

  // --- Kayıtlı listeler ---

  /// Mevcut sepeti isimlendirip saklar. Aynı isim varsa üzerine yazar.
  SavedList? saveCurrentBasket(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _items.isEmpty) return null;

    final now = DateTime.now();
    final snapshotItems = [..._items];
    final existing = _savedLists.indexWhere(
      (l) => l.name.toLowerCase() == trimmed.toLowerCase(),
    );

    late final SavedList saved;
    if (existing >= 0) {
      saved = _savedLists[existing].copyWith(
        items: snapshotItems,
        updatedAt: now,
      );
      _savedLists[existing] = saved;
    } else {
      saved = SavedList(
        id: _newId(),
        name: trimmed,
        items: snapshotItems,
        createdAt: now,
        updatedAt: now,
      );
      _savedLists.insert(0, saved);
    }

    _sortSavedLists();
    _repository.saveSavedLists(_savedLists);
    notifyListeners();
    return saved;
  }

  void deleteSavedList(String id) {
    _savedLists.removeWhere((l) => l.id == id);
    _repository.saveSavedLists(_savedLists);
    notifyListeners();
  }

  void renameSavedList(String id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final index = _savedLists.indexWhere((l) => l.id == id);
    if (index < 0) return;
    _savedLists[index] = _savedLists[index].copyWith(
      name: trimmed,
      updatedAt: DateTime.now(),
    );
    _sortSavedLists();
    _repository.saveSavedLists(_savedLists);
    notifyListeners();
  }

  /// [merge] `false` ise sepeti listeyle değiştirir, `true` ise üstüne ekler.
  void loadSavedList(String id, {bool merge = false}) {
    final index = _savedLists.indexWhere((l) => l.id == id);
    if (index < 0) return;
    _applyItems(_savedLists[index].items, merge: merge);
  }

  // --- Karşılaştırma geçmişi ---

  void _recordHistory(ComparisonResult result) {
    final snapshot = ComparisonSnapshot.fromResult(
      result,
      items: [..._items],
      id: _newId(),
    );
    _history.insert(0, snapshot);
    if (_history.length > BasketRepository.historyLimit) {
      _history = _history.take(BasketRepository.historyLimit).toList();
    }
    _repository.saveHistory(_history);
  }

  void deleteSnapshot(String id) {
    _history.removeWhere((s) => s.id == id);
    _repository.saveHistory(_history);
    notifyListeners();
  }

  void clearHistory() {
    _history = [];
    _repository.saveHistory(_history);
    notifyListeners();
  }

  /// Geçmişteki bir karşılaştırmanın sepetini geri yükler.
  void restoreSnapshot(String id, {bool merge = false}) {
    final index = _history.indexWhere((s) => s.id == id);
    if (index < 0) return;
    _applyItems(_history[index].items, merge: merge);
  }

  void _applyItems(List<ListItem> items, {required bool merge}) {
    if (!merge) _items.clear();
    for (final item in items) {
      final existing = _items.indexWhere(
        (i) => i.product.id == item.product.id,
      );
      if (existing >= 0) {
        _items[existing] = _items[existing].copyWith(
          quantity: _items[existing].quantity + item.quantity,
        );
      } else {
        _items.add(item);
      }
    }
    _lastResult = null;
    _error = null;
    _persistBasket();
    notifyListeners();
  }

  void _sortSavedLists() {
    _savedLists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  void _persistBasket() => _repository.saveBasket(_items);

  int _idCounter = 0;
  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_idCounter++}';
}
