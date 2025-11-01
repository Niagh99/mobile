import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Không tìm thấy người dùng'};
      }
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      // Reauthenticate để xác minh mật khẩu cũ
      await user.reauthenticateWithCredential(cred);

      // Đổi mật khẩu trong Firebase Authentication
      await user.updatePassword(newPassword);

      // Cập nhật lại mật khẩu trong Firestore (nếu bạn có lưu trường "password")
      await _firestore.collection('users').doc(user.uid).update({
        'password': newPassword,
      });

      return {'success': true, 'message': 'Đổi mật khẩu thành công!'};
    } on FirebaseAuthException catch (e) {
      String msg = 'Đã xảy ra lỗi';
      if (e.code == 'wrong-password') {
        msg = 'Mật khẩu cũ không đúng';
      } else if (e.code == 'weak-password') {
        msg = 'Mật khẩu mới quá yếu';
      } else if (e.code == 'requires-recent-login') {
        msg = 'Vui lòng đăng nhập lại để đổi mật khẩu';
      }
      return {'success': false, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: ${e.toString()}'};
    }
  }
}
