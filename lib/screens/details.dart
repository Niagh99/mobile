import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import 'cart_provider.dart';

class Details extends StatelessWidget {
  final Food food;

  const Details({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    // Hàm hiển thị ảnh phù hợp (URL hoặc Asset)
    Widget buildImage(String imageUrl) {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        );
      } else {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
            );
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh món ăn
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: buildImage(food.imageUrl),
            ),
            const SizedBox(height: 20),

            // 💰 Giá món ăn
            Text(
              'Giá: ${food.price.toStringAsFixed(0)} VNĐ',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),

            // 📝 Miêu tả
            const Text(
              'Miêu tả món ăn:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              food.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 30),

            // 🛒 Nút thêm vào giỏ hàng
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  "Thêm vào giỏ hàng",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  cartProvider.addToCart(food);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🛒 Đã thêm "${food.name}" vào giỏ hàng!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
