import 'package:flutter/foundation.dart';

import '../models/comparison_result.dart';
import '../models/list_item.dart';
import '../models/product.dart';
import '../services/price_service.dart';

class BasketController extends ChangeNotifier {
  BasketController(this._priceService);

  final PriceService _priceService;

  final List<ListItem> _items = [];
  ComparisonResult? _lastResult;
  bool _comparing = false;
  String? _error;

  List<ListItem> get items => List.unmodifiable(_items);
  ComparisonResult? get lastResult => _lastResult;
  bool get comparing => _comparing;
  String? get error => _error;
  int get totalQuantity =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

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
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _lastResult = null;
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
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _lastResult = null;
    _error = null;
    notifyListeners();
  }

  Future<ComparisonResult?> compare() async {
    if (_items.isEmpty) return null;
    _comparing = true;
    _error = null;
    notifyListeners();
    try {
      _lastResult = await _priceService.compareBasket(_items);
      return _lastResult;
    } catch (e) {
      _error = 'Fiyatlar alınamadı. Tekrar deneyin.';
      return null;
    } finally {
      _comparing = false;
      notifyListeners();
    }
  }

  Future<List<Product>> search(String query) =>
      _priceService.searchProducts(query);
}
