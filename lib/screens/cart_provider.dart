import 'package:flutter/material.dart';
import '../models/food.dart';

class CartProvider extends ChangeNotifier {
  final Map<Food, int> _items = {};
  final Set<Food> _selectedItems = {};

  Map<Food, int> get items => _items;
  Set<Food> get selectedItems => _selectedItems;

  double get totalPrice => _selectedItems.isEmpty
      ? _items.entries.fold(0, (sum, e) => sum + e.key.price * e.value)
      : _selectedItems.fold(0, (sum, food) => sum + (food.price * (_items[food] ?? 0)));

  int get totalItems => _items.values.fold(0, (sum, quantity) => sum + quantity);

  void addToCart(Food food) {
    if (_items.containsKey(food)) {
      _items[food] = _items[food]! + 1;
    } else {
      _items[food] = 1;
    }
    notifyListeners();
  }

  void removeFromCart(Food food) {
    _items.remove(food);
    _selectedItems.remove(food);
    notifyListeners();
  }

  void increaseQuantity(Food food) {
    _items[food] = _items[food]! + 1;
    notifyListeners();
  }

  void decreaseQuantity(Food food) {
    if (_items[food]! > 1) {
      _items[food] = _items[food]! - 1;
    } else {
      _items.remove(food);
      _selectedItems.remove(food);
    }
    notifyListeners();
  }

  void toggleSelection(Food food) {
    if (_selectedItems.contains(food)) {
      _selectedItems.remove(food);
    } else {
      _selectedItems.add(food);
    }
    notifyListeners();
  }

  void clearSelectedItems() {
    _items.removeWhere((food, _) => _selectedItems.contains(food));
    _selectedItems.clear();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _selectedItems.clear();
    notifyListeners();
  }
}
