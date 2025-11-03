import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      rethrow;
    }
  }
  

  //Lấy danh sách đơn hàng (realtime stream)
  Stream<QuerySnapshot> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  //Tạo đơn hàng mới
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        orderData['userId'] = user.uid;
        orderData['email'] = user.email;
      }
      orderData['createdAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('orders').add(orderData);
    } catch (e) {
      rethrow;
    }
  }

  //Lấy danh sách đơn hàng (1 lần, không realtime)
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  //Stream đơn hàng của người dùng hiện tại (realtime)
  Stream<List<Map<String, dynamic>>> getUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}
