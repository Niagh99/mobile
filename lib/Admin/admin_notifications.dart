import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  //Hai controller để đọc dữ liệu từ TextField
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;// tránh bị spam

  Future<void> _sendNotification() async {
    setState(() => _isSending = true);
    // hàm gửi thông báo đến tất cả user
    await NotificationService.sendNotificationToAllUsers(
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
    );

    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi thông báo đến user!')),
    );

    _titleController.clear();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gửi thông báo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Nội dung'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSending ? null : _sendNotification,
              icon: const Icon(Icons.send),
              label: _isSending
                  ? const Text('Đang gửi...')
                  : const Text('Gửi thông báo'),
            ),
          ],
        ),
      ),
    );
  }
}
