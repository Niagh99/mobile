import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // UID CỦA ADMIN
  static const String adminId = 'YAKnSu3CCQQM7zaqUbVALoD3pbO2';

  // ===========================================================
  // PHẦN SẢN PHẨM
  // ===========================================================

  Future<void> addFood(Food food) async {
    try {
      await _firestore.collection('foods').doc(food.id).set(food.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Food>> getFoods() async {
    try {
      final snapshot = await _firestore.collection('foods').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Food.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Food>> getFoodsStream() {
    return _firestore.collection('foods').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Food.fromMap(data);
      }).toList();
    });
  }

  Future<void> updateFood(Food food) async {
    try {
      await _firestore.collection('foods').doc(food.id).update(food.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFood(String id) async {
    try {
      await _firestore.collection('foods').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===========================================================
  // 🔶 PHẦN TÀI KHOẢN / ROLE / XÁC THỰC
  // ===========================================================

  Future<User?> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final userData = {
          'uid': user.uid,
          'email': email,
          'name': name,
          'role': 'user',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).set(userData);
        return user;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // 🔹 Kiểm tra isActive
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'no-user-data',
          message: 'Không tìm thấy thông tin người dùng.',
        );
      }

      final data = userDoc.data()!;
      final isActive = data['isActive'] ?? true;

      if (!isActive) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'Tài khoản của bạn đã bị vô hiệu hóa.',
        );
      }

      return user;
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (e) {
      return null;
    }
  }
// lấy thông tin user theo uid
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }
// lấy thông tin user hiện tại
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'];
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ===========================================================
  // 🔶 PHẦN CHAT REALTIME (USER ↔ ADMIN)
  // ===========================================================

  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || text.trim().isEmpty) return;

    final senderId = currentUser.uid;
    final chatId = senderId == adminId ? receiverId : senderId;
    final chatRef = _firestore.collection('chats').doc(chatId);

    final message = {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': senderId == adminId ? false : true,
    };

    await chatRef.collection('messages').add(message);

    await chatRef.set({
      'participants': [chatId, adminId],
      'lastMessage': text,
      'lastMessageSender': senderId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatUsers() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: adminId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getCurrentUserChat() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Stream<int> getUnreadMessageCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    final chatId = currentUser.uid;
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isEqualTo: adminId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markMessagesAsRead() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final chatId = currentUser.uid;
    final messagesRef =
        _firestore.collection('chats').doc(chatId).collection('messages');

    final unreadMessages = await messagesRef
        .where('senderId', isEqualTo: adminId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
