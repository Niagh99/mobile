import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import '../models/food.dart';
import 'admin_details.dart';
import '../screens/profile.dart';
import '../Admin/admin_orders.dart';
import '../services/firebase_service.dart';
import '../product/add.dart';
import '../product/Edit.dart';
import 'admin_chat_list.dart';
import 'admin_notifications.dart';

bool hasShownLoginSnackbar = false;
// ======================= MÀN HÌNH CHÍNH ADMIN =======================
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    FoodListScreen(),
    ProfilePage(),
    AdminUserOrdersScreen(),
    AdminNotificationScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        actions: [
          // === ICON CHAT ===
          IconButton(
            icon: const Icon(Icons.chat, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminChatList()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 12,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu, color: Colors.orange),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: Colors.orange),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment, color: Colors.orange),
            label: 'Đơn hàng',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications, color: Colors.orange),
            label: 'Thông báo',
          ),
        ],
      ),
    );
  }
}

// ======================= FOOD LIST PAGE (ADMIN) =======================
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
              'Chào mừng Admin!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 3),
            elevation: 6,
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
      _showSnackBar('Lỗi load dữ liệu: $e', Colors.red);
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

  void _deleteFood(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                await FirebaseService().deleteFood(id);
                if (mounted) Navigator.pop(context);
                await _loadFoods();
                if (mounted) {
                  _showSnackBar('Xóa sản phẩm thành công!', Colors.green);
                }
              } catch (e) {
                if (mounted) {
                  _showSnackBar('Lỗi xóa: $e', Colors.red);
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Column(
        children: [
          // Header: Tìm kiếm + Sắp xếp
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thanh tìm kiếm
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.orange.shade300, width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterFoods,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Tìm món ăn...',
                        prefixIcon: Icon(Icons.search, color: Colors.orange),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nút sắp xếp
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.orange.shade400, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortOption,
                      icon: const Icon(Icons.sort, color: Colors.orange),
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('Mặc định')),
                        DropdownMenuItem(value: 'asc', child: Text('Giá tăng dần')),
                        DropdownMenuItem(value: 'desc', child: Text('Giá giảm dần')),
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
          // Danh sách sản phẩm
          Expanded(
            child: filteredFoods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Không có sản phẩm nào',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = filteredFoods[index];
                      return Card(
                        elevation: 8,
                        shadowColor: Colors.black26,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AdminDetails(food: food)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Hình ảnh
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: food.imageUrl.startsWith('http')
                                      ? Image.network(
                                          food.imageUrl,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.error, color: Colors.red),
                                          ),
                                        )
                                      : Image.asset(
                                          food.imageUrl,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const SizedBox(width: 16),
                                // Thông tin
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        food.description,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${food.price.toStringAsFixed(0)} VNĐ',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Nút hành động
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                                      onPressed: () => edit_food(context, food, _loadFoods),
                                      splashRadius: 20,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                                      onPressed: () => _deleteFood(food.id),
                                      splashRadius: 20,
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => add_food(context, _loadFoods),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add, size: 26),
        label: const Text('Thêm món', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}