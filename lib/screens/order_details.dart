import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng của bạn'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: OrderService().getUserOrdersStream(), //chỉ lấy đơn hàng của user
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi khi tải đơn hàng: ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa có đơn hàng nào!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = List<Map<String, dynamic>>.from(order['items']);
              final totalPrice = (order['totalPrice'] as num).toDouble();

              // ✅ Sửa lỗi Timestamp
              final createdAtField = order['createdAt'];
              DateTime createdAt;

              if (createdAtField is Timestamp) {
                createdAt = createdAtField.toDate();
              } else if (createdAtField is String) {
                createdAt = DateTime.parse(createdAtField);
              } else {
                createdAt = DateTime.now();
              }

              final formattedDate =
                  DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

              final status = order['status'] ?? 'Đang xử lý';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🧾 Đơn hàng #${order['id']?.substring(0, 8) ?? "N/A"}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('🕓 Ngày đặt: $formattedDate'),
                      Text('📞 SĐT: ${order['phone'] ?? "Không có"}'),
                      Text('📍 Địa chỉ: ${order['address'] ?? "Không có"}'),
                      if (order['note'] != null &&
                          (order['note'] as String).isNotEmpty)
                        Text('📝 Ghi chú: ${order['note']}'),
                      Text('🚚 Trạng thái: $status'),
                      const SizedBox(height: 8),
                      const Text(
                        'Sản phẩm:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...items.map((item) => ListTile(
                            title: Text('${item['name']} (x${item['quantity']})'),
                            subtitle:
                                Text('${item['price'].toStringAsFixed(0)} VNĐ'),
                          )),
                      const SizedBox(height: 8),
                      Text(
                        '💰 Tổng cộng: ${totalPrice.toStringAsFixed(0)} VNĐ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
