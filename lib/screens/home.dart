import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badge;
import '../models/food.dart';
import '../screens/details.dart';
import '../screens/cart_screen.dart';
import '../screens/profile.dart';
import 'order_details.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'cart_provider.dart';

bool hasShownLoginSnackbar = false;

// ======================= MÀN HÌNH CHÍNH =======================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    FoodListScreen(),
    ProfilePage(),
    OrderScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food App'),
        backgroundColor: Colors.orange,
        actions: [
          badge.Badge(
            badgeContent: Text(
              '${cart.totalItems}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            showBadge: cart.totalItems > 0,
            badgeStyle: const badge.BadgeStyle(
              badgeColor: Colors.red,
              padding: EdgeInsets.all(4),
              borderSide: BorderSide(color: Colors.white, width: 1),
            ),
            position: badge.BadgePosition.topEnd(top: 1, end: 1),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Danh sách'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Đơn hàng'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ======================= FOOD LIST PAGE =======================
class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  List<Food> foods = [];
  List<Food> filteredFoods = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'none';

  @override
  void initState() {
    super.initState();
    _loadFoods();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasShownLoginSnackbar) {
        hasShownLoginSnackbar = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Đăng nhập thành công!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    final service = FirebaseService();
    try {
      final loadedFoods = await service.getFoods();
      setState(() {
        foods = loadedFoods;
        filteredFoods = loadedFoods;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi load dữ liệu: $e')),
      );
    }
  }

  void _filterFoods(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFoods = foods;
      } else {
        final normalizedQuery = removeDiacritics(query.toLowerCase());
        filteredFoods = foods.where((food) {
          final name = removeDiacritics(food.name.toLowerCase());
          return name.contains(normalizedQuery);
        }).toList();
      }
      _applySort();
    });
  }

  void _applySort() {
    if (_sortOption == 'asc') {
      filteredFoods.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'desc') {
      filteredFoods.sort((a, b) => b.price.compareTo(a.price));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text(
          'Thực đơn hôm nay',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.orange,
        elevation: 3,
        centerTitle: true,
        actions: [
          // === BADGE TIN NHẮN CHƯA ĐỌC ===
          StreamBuilder<int>(
            stream: FirebaseService().getUnreadMessageCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;

              return badge.Badge(
                showBadge: unreadCount > 0,
                badgeContent: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: const badge.BadgeStyle(
                  badgeColor: Colors.red,
                  padding: EdgeInsets.all(5),
                ),
                position: badge.BadgePosition.topEnd(top: -1, end: -1),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () async {
                   await FirebaseService().markMessagesAsRead();
                   Navigator.push( context,
                     MaterialPageRoute(
                       builder: (_) => ChatScreen(
                       chatId: currentUser!.uid,
                       receiverId: FirebaseService.adminId,
                       isAdmin: false,
                       ),
                     ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm + dropdown lọc giá
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterFoods,
                    decoration: InputDecoration(
                      hintText: 'Tìm món ăn...',
                      prefixIcon: const Icon(Icons.search, color: Colors.orange),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.orange, width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortOption,
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('Mặc định')),
                        DropdownMenuItem(value: 'asc', child: Text('Giá tăng')),
                        DropdownMenuItem(value: 'desc', child: Text('Giá giảm')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortOption = value!;
                          _applySort();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách món ăn
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredFoods.length,
              itemBuilder: (context, index) {
                final food = filteredFoods[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Details(food: food)),
                    );
                  },
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: food.imageUrl.startsWith('http')
                                ? Image.network(food.imageUrl,
                                    width: 120, height: 120, fit: BoxFit.cover)
                                : Image.asset(food.imageUrl,
                                    width: 120, height: 120, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  food.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${food.price.toStringAsFixed(0)} VNĐ',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}