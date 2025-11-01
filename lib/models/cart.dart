import 'food.dart';

/// Lớp CartItem đại diện cho 1 món trong giỏ hàng
class CartItem {
  final Food food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

/// Lớp Cart để quản lý danh sách món trong giỏ hàng
class Cart {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  /// Thêm món ăn vào giỏ (nếu đã có thì tăng số lượng)
  static void addItem(Food food) {
    final index = _items.indexWhere((item) => item.food.id == food.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(food: food));
    }
  }

  /// Xóa món khỏi giỏ
  static void removeItem(String id) {
    _items.removeWhere((item) => item.food.id == id);
  }

  /// Tính tổng tiền
  static double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.food.price * item.quantity);
  }

  /// Xóa toàn bộ giỏ hàng
  static void clear() {
    _items.clear();
  }
}
