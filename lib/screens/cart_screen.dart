import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'cart_details.dart';

/// Màn hình hiển thị giỏ hàng
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Widget _buildFoodImage(String imageUrl) {
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
            // Hiển thị tổng tiền hoặc thông báo chưa chọn món
            Text(
              cart.selectedItems.isEmpty
                  ? 'Chưa chọn món nào'
                  : 'Tổng: ${cart.totalPrice.toStringAsFixed(0)} VNĐ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            // 🟢 Nút thanh toán chỉ bật khi có món được chọn
            ElevatedButton(
              onPressed: cart.selectedItems.isEmpty
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
                                const SnackBar(
                                    content: Text('Thanh toán thành công!')),
                              );
                            },
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
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
