import 'package:flutter/material.dart';
import '../models/food.dart';
import 'package:provider/provider.dart';
import 'cart_details.dart'; 

/// Provider quản lý giỏ hàng
class CartProvider extends ChangeNotifier {
  final Map<Food, int> _items = {};
  final Set<Food> _selectedItems = {}; // Lưu các sản phẩm được chọn

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

/// Màn hình hiển thị giỏ hàng
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Widget _buildFoodImage(String imageUrl) {
    // Kiểm tra xem ảnh là asset hay là URL
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 60, color: Colors.grey),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 60,
              height: 60,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 60, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        backgroundColor: Colors.orange,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => cart.clearCart(),
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Giỏ hàng trống!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final food = cart.items.keys.elementAt(index);
                final quantity = cart.items.values.elementAt(index);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: cart.selectedItems.contains(food),
                          onChanged: (value) => cart.toggleSelection(food),
                        ),
                        _buildFoodImage(food.imageUrl),
                      ],
                    ),
                    title: Text(
                      food.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${food.price.toStringAsFixed(0)} VNĐ x $quantity',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => cart.decreaseQuantity(food),
                        ),
                        Text('$quantity'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => cart.increaseQuantity(food),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tổng: ${cart.totalPrice.toStringAsFixed(0)} VNĐ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            ElevatedButton(
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartDetailsScreen(
                            totalPrice: cart.totalPrice,
                            selectedItems: cart.selectedItems.toList(),
                            onPaymentSuccess: () {
                              cart.clearSelectedItems();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Thanh toán thành công!')),
                              );
                            },
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
