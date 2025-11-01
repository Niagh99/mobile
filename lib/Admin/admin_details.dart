import 'package:flutter/material.dart';
import '../models/food.dart';

class AdminDetails extends StatelessWidget {
  final Food food; // Món ăn được chọn

  const AdminDetails({super.key, required this.food});

  // 🔹 Hàm hiển thị ảnh thông minh (URL hoặc Asset)
  Widget buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      // Nếu là URL
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
        //hiện thị vòng tròn tải khi ảnh đang load
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      // Nếu là asset
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết món ăn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Ảnh món ăn
            ClipRRect(
              borderRadius: BorderRadius.circular(12), //bo góc ảnh
              child: buildImage(food.imageUrl),
            ),
            const SizedBox(height: 20),
            //Tên & Giá món ăn
            Text(
              food.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Giá: ${food.price.toStringAsFixed(0)} VNĐ',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            //Mô tả món ăn
            const Text(
              'Mô tả:',
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
