import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart'; 

class AdminUserOrdersScreen extends StatelessWidget {
  const AdminUserOrdersScreen({super.key});

  // Lấy danh sách user (role: user)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  // Cập nhật trạng thái hoạt động user
  Future<void> toggleUserActive(String userId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'isActive': !currentStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Quản lý người dùng'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Lỗi khi tải danh sách người dùng: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Text(
                'Không có người dùng nào!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final name = user['name'] ?? 'Không tên';
              final email = user['email'] ?? 'Không có email';
              final bool isActive = user['isActive'] ?? true;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            isActive
                                ? '🟢 Đang hoạt động'
                                : '🔴 Bị vô hiệu hóa',
                            style: TextStyle(
                              color: isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Switch(
                    activeColor: Colors.orange,
                    value: isActive,
                    onChanged: (value) async {
                      await toggleUserActive(user['id'], isActive);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isActive
                              ? '🚫 Đã vô hiệu hóa ${user['name']}'
                              : '✅ Đã kích hoạt lại ${user['name']}'),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserOrdersDetailScreen(
                          userId: user['id'],
                          userName: name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserOrdersDetailScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserOrdersDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  Stream<List<Map<String, dynamic>>> getOrdersStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  @override
  Widget build(BuildContext context) {
    final OrderService orderService = OrderService(); // khởi tạo service
    final List<String> allowedStatuses = ['đã duyệt', 'đang giao', 'đã hủy'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng của $userName'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi khi tải đơn hàng: ${snapshot.error}'),
            );
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text('Người dùng này chưa có đơn hàng nào.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = List<Map<String, dynamic>>.from(order['items']);
              final totalPrice = (order['totalPrice'] as num).toDouble();

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
              final orderId = order['id'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🧾 Đơn hàng #${orderId.substring(0, 8)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('🕓 Ngày đặt: $formattedDate'),
                      Text('📞 SĐT: ${order['phone'] ?? 'Không có'}'),
                      Text('📍 Địa chỉ: ${order['address'] ?? 'Không có'}'),
                      if (order['note'] != null &&
                          (order['note'] as String).isNotEmpty)
                        Text('📝 Ghi chú: ${order['note']}'),

                      // 🔽 Dropdown thay đổi trạng thái
                      Row(
                        children: [
                          const Text('🚚 Trạng thái: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: allowedStatuses.contains(status)
                                ? status
                                : null,
                            hint: Text(status),
                            items: allowedStatuses.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newStatus) async {
                              if (newStatus != null) {
                                await orderService.updateOrderStatus(orderId, newStatus);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('✅ Đã cập nhật trạng thái: $newStatus')),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      const Text('Sản phẩm:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...items.map((item) => ListTile(
                            title: Text(
                                '${item['name']} (x${item['quantity']})'),
                            subtitle:
                                Text('${item['price'].toStringAsFixed(0)} VNĐ'),
                          )),
                      const SizedBox(height: 8),
                      Text('💰 Tổng cộng: ${totalPrice.toStringAsFixed(0)} VNĐ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
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
