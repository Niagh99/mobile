import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Login/login_screen.dart';
import 'screens/home.dart';
import 'screens/cart_screen.dart';
import 'services/firebase_service.dart'; 
import 'Admin/AdminHomeScreen.dart'; 

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _initializeOneSignal() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("7b2b4268-6b4a-473a-ad35-942c9d6558b8");
  OneSignal.Notifications.requestPermission(true);
  OneSignal.Notifications.addClickListener((event) {
    navigatorKey.currentState?.pushNamed('/home');
  });
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _initializeOneSignal();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService(); 

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food App',
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Nếu chưa đăng nhập
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // Nếu đã đăng nhập, kiểm tra role
          final user = snapshot.data!;
          return FutureBuilder<String?>(
            future: _firebaseService.getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!roleSnapshot.hasData) {
                return const LoginScreen(); // Không lấy được role thì quay về đăng nhập
              }

              final role = roleSnapshot.data;
              if (role == 'admin') {
                return const AdminHomeScreen(); // màn hình admin
              } else {
                return const HomeScreen(); //Màn hình user bình thường
              }
            },
          );
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/adminHome': (context) => const AdminHomeScreen(),
      },
    );
  }
}
