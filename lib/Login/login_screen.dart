import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    });
  }
//hàm xử lý đăng nhập và đăng ký
  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // 🔹 Đăng nhập bằng email / mật khẩu
        try {
          final user = await firebaseService.loginUser(
            email: email,
            password: password,
          );

          if (user != null) {
            final role = await firebaseService.getUserRole(user.uid);
            if (role == 'admin') {
              Navigator.pushReplacementNamed(context, '/adminHome');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng nhập thất bại!')),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-disabled') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Tài khoản của bạn đã bị vô hiệu hóa.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? 'Đăng nhập thất bại.')),
            );
          }
        }
      } else {
        // 🔹 Đăng ký tài khoản mới
        final user = await firebaseService.registerUser(
          email: email,
          password: password,
          name: name,
        );

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký thành công!')),
          );
          setState(() => isLogin = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký thất bại!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Đăng nhập bằng Google
  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final userCredential = await AuthService.instance.signInWithGoogle();
      final user = userCredential.user;

      if (user != null) {
        final role = await firebaseService.getUserRole(user.uid);
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/adminHome');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập Google thất bại: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fastfood, size: 80, color: Colors.orange),
                const SizedBox(height: 10),
                Text(
                  isLogin ? 'Chào mừng trở lại!' : 'Tạo tài khoản mới',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLogin
                      ? 'Đăng nhập để tiếp tục'
                      : 'Hãy nhập thông tin để bắt đầu',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 30),

                if (!isLogin)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Họ tên',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.orange[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                if (!isLogin) const SizedBox(height: 15),

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.orange[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.orange[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                isLoading
                    ? const CircularProgressIndicator(color: Colors.orange)
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor: Colors.orangeAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 70, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          isLogin ? 'Đăng nhập' : 'Đăng ký',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),

                const SizedBox(height: 18),

                // Thêm nút đăng nhập bằng Google
                if (isLogin) ...[
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      side: const BorderSide(color: Colors.orange, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    label: const Text(
                      'Đăng nhập bằng Google',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                GestureDetector(
                  onTap: _toggleForm,
                  child: Text(
                    isLogin
                        ? "Chưa có tài khoản? Đăng ký ngay"
                        : "Đã có tài khoản? Đăng nhập",
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
