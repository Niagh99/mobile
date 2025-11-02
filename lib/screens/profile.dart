import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import '../services/firebase_service.dart';
import 'change_password.dart';
import 'cart_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _firebaseService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _userData = user;
      });
    }
  }

  void _logout(BuildContext context) async {
    await _firebaseService.logout();

    // 🧹 Xóa toàn bộ giỏ hàng khi user đăng xuất (dùng Provider)
    Provider.of<CartProvider>(context, listen: false).clearCart();

    hasShownLoginSnackbar = false;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Hàm mở trang đổi mật khẩu
  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Tài khoản"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Avatar + tên
                  Column(
                    children: [
                      _buildProfileAvatar(),
                      const SizedBox(height: 12),
                      Text(
                        _userData?['name'] ?? 'Không có tên',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData?['role'] == 'admin'
                            ? 'Quản trị viên'
                            : 'Người dùng',
                        style: TextStyle(
                          fontSize: 14,
                          color: _userData?['role'] == 'admin'
                              ? Colors.red
                              : const Color.fromARGB(255, 16, 16, 16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Thông tin cá nhân
                  _infoCard(
                    title: "Email",
                    subtitle: _userData?['email'] ?? 'Lỗi lấy email',
                    icon: Icons.email_outlined,
                    iconColor: Colors.blueAccent,
                  ),
                  _infoCard(
                    title: "UID",
                    subtitle: _userData?['uid'] ?? 'Lỗi lấy UID',
                    icon: Icons.perm_identity,
                    iconColor: Colors.grey,
                  ),

                  // ✅ Thay đổi mật khẩu
                  _actionCard(
                    title: "Thay đổi mật khẩu",
                    subtitle: "Thay đổi mật khẩu cho tài khoản của bạn",
                    onTap: _changePassword,
                  ),

                  const SizedBox(height: 30),

                  // Nút đăng xuất
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Đăng xuất tài khoản",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 🧩 Avatar hiển thị theo role
  Widget _buildProfileAvatar() {
    if (_userData == null) {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 40, color: Colors.white),
      );
    }

    final role = _userData?['role'];
    if (role == 'admin') {
      return const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage("images/Avatar.jpg"),
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 40, color: Colors.white),
      );
    }
  }

  // Widget hiển thị thông tin
  Widget _infoCard({
    required String title,
    required String subtitle,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          if (icon != null)
            Icon(icon, color: iconColor ?? Colors.grey, size: 20),
        ],
      ),
    );
  }

  // Widget hành động (thay đổi mật khẩu, v.v.)
  Widget _actionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
