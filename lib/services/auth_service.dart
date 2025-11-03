import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  /// Đăng nhập Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});

      UserCredential userCredential;

      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        userCredential = await _auth.signInWithProvider(googleProvider);
      }

      final user = userCredential.user;
      if (user == null) throw Exception('Không thể lấy thông tin người dùng.');

      // Kiểm tra Firestore, nếu chưa có thì tạo
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? 'Người dùng',
          'role': 'user',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: explainAuthError(e),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

/// Giải thích lỗi dễ hiểu hơn
String explainAuthError(FirebaseAuthException error) {
  switch (error.code) {
    case 'account-exists-with-different-credential':
      return 'Email này đã được đăng ký bằng phương thức khác.';
    case 'user-disabled':
      return 'Tài khoản của bạn đã bị vô hiệu hóa.';
    case 'popup-closed-by-user':
      return 'Bạn đã đóng cửa sổ đăng nhập.';
    case 'network-request-failed':
      return 'Lỗi mạng, vui lòng kiểm tra kết nối.';
    default:
      return 'Đăng nhập thất bại: ${error.message}';
  }
}
