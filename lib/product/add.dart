import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/firebase_service.dart';

void add_food(BuildContext context, Future<void> Function() onAdded) {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Thêm sản phẩm mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idController, decoration: const InputDecoration(labelText: 'ID (unique)')),
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
              final messenger = ScaffoldMessenger.of(context);

              // Kiểm tra input
              if (idController.text.isEmpty ||
                  nameController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  imageController.text.isEmpty ||
                  priceController.text.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                );
                return;
              }

              final priceText = priceController.text.trim();
              if (double.tryParse(priceText) == null) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Giá phải là số hợp lệ')),
                );
                return;
              }

              final newFood = Food(
                id: idController.text,
                name: nameController.text,
                description: descriptionController.text,
                imageUrl: imageController.text,
                price: double.parse(priceText),
                category: 'Uncategorized',
                extraImages: [],
                ingredients: [],
              );

              try {
                await FirebaseService().addFood(newFood);
                Navigator.pop(context);
                await onAdded();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Thêm sản phẩm thành công!')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Lỗi thêm sản phẩm: $e')),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      );
    },
  );
}
