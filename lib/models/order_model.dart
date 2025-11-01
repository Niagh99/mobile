import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final String email;
  final String status;
  final double total;
  final List<Map<String, dynamic>> items;
  final DateTime? createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.email,
    required this.status,
    required this.total,
    required this.items,
    this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> data, String documentId) {
    return Order(
      id: documentId,
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      status: data['status'] ?? 'pending',
      total: (data['total'] ?? 0).toDouble(),
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'status': status,
      'total': total,
      'items': items,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
