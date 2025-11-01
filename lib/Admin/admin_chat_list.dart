import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../screens/chat_screen.dart';

class AdminChatList extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  AdminChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách người dùng")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getChatUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("Chưa có người dùng nào nhắn tin."));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final chatId = chatDoc.id; // Đây chính là UID của user
              final chatData = chatDoc.data() as Map<String, dynamic>;// chứa nội dung dữ liệu được truyền về

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(chatId)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const ListTile(title: Text("Đang tải..."));
                  }

                  final userData = userSnap.data!.data() as Map<String, dynamic>?;
                  final userName = userData?['name'] ?? 'Người dùng $chatId';

                  return ListTile(
                    title: Text(userName),
                    subtitle: Text(chatData['lastMessage'] ?? ''),
                    trailing: const Icon(Icons.chat),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId,
                            receiverId: chatId,
                            isAdmin: true,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}