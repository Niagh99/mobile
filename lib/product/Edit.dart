import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/firebase_service.dart';

void edit_food(BuildContext context, Food food, Future<void> Function() onUpdated) {
  // Khởi tạo các controller với dữ liệu hiện tại
  final TextEditingController idController = TextEditingController(text: food.id);
  final TextEditingController nameController = TextEditingController(text: food.name);
  final TextEditingController descriptionController = TextEditingController(text: food.description);
  final TextEditingController imageController = TextEditingController(text: food.imageUrl);
  final TextEditingController priceController = TextEditingController(text: food.price.toString());

  // Hiển thị dialog
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sửa sản phẩm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idController, decoration: const InputDecoration(labelText: 'ID (không thể thay đổi)'), readOnly: true),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Mô tả')),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image URL hoặc asset')),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              // Kiểm tra input có đầy đủ không
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  imageController.text.isEmpty ||
                  priceController.text.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')));
                return;
              }

              // Tạo object Food cập nhật
              final updatedFood = Food(
                id: food.id, // Giữ nguyên ID
                name: nameController.text,
                description: descriptionController.text,
                imageUrl: imageController.text,
                price: double.parse(priceController.text),
                category: food.category,
                extraImages: food.extraImages,
                ingredients: food.ingredients,
              );

              try {
                // Cập nhật vào Firebase
                await FirebaseService().updateFood(updatedFood);
                Navigator.pop(context);
                // Gọi callback để reload danh sách
                await onUpdated();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Sửa sản phẩm thành công!')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Lỗi sửa sản phẩm: $e')));
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      );
    },
  );
}