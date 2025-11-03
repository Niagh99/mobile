import 'package:flutter/material.dart';
import '../models/food.dart';

class CartProvider extends ChangeNotifier {
  final Map<Food, int> _items = {};
  final Set<Food> _selectedItems = {};

  Map<Food, int> get items => _items;
  Set<Food> get selectedItems => _selectedItems;

  double get totalPrice {
   if (_selectedItems.isEmpty) return 0;
   return _selectedItems.fold(0, (sum, food) {
     final quantity = _items[food] ?? 0;
     return sum + food.price * quantity;
   });
  }
  int get totalItems => _items.values.fold(0, (sum, quantity) => sum + quantity);
// thêm món vào giỏ hàng
  void addToCart(Food food) {
    if (_items.containsKey(food)) {
      _items[food] = _items[food]! + 1;
    } else {
      _items[food] = 1;
    }
    notifyListeners();
  }
// xóa món khỏi giỏ hàng
  void removeFromCart(Food food) {
    _items.remove(food);
    _selectedItems.remove(food);
    notifyListeners();
  }
// tăng số lượng món trong giỏ hàng
  void increaseQuantity(Food food) {
    _items[food] = _items[food]! + 1;
    notifyListeners();
  }
// giảm số lượng món trong giỏ hàng
  void decreaseQuantity(Food food) {
    if (_items[food]! > 1) {
      _items[food] = _items[food]! - 1;
    } else {
      _items.remove(food);
      _selectedItems.remove(food);
    }
    notifyListeners();
  }
// chọn hoặc bỏ chọn món trong giỏ hàng
  void toggleSelection(Food food) {
    if (_selectedItems.contains(food)) {
      _selectedItems.remove(food);
    } else {
      _selectedItems.add(food);
    }
    notifyListeners();
  }
// xóa các món đã chọn khỏi giỏ hàng
  void clearSelectedItems() {
    _items.removeWhere((food, _) => _selectedItems.contains(food));
    _selectedItems.clear();
    notifyListeners();
  }
// xóa toàn bộ giỏ hàng
  void clearCart() {
    _items.clear();
    _selectedItems.clear();
    notifyListeners();
  }
}
