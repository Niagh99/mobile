import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String oneSignalAppId = '7b2b4268-6b4a-473a-ad35-942c9d6558b8';
  static const String restApiKey =
      'os_v2_app_pmvue2dljjdtvljvsqwj2zkyxadu4llyq5fek6ng253o5qkbshyi237vnwi7lwbs3xgfz4mtnzxm5222e4a4yeuvvwxbyv63t3d5gzi';

  static Future<void> sendNotificationToAllUsers({
    required String title,
    required String message,
  }) async {
    const String url = 'https://onesignal.com/api/v1/notifications';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $restApiKey',
        },
        body: jsonEncode({
          'app_id': oneSignalAppId,
          'included_segments': ['All'],
          'headings': {'en': title},
          'contents': {'en': message},
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gửi thông báo thất bại: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gửi thông báo: $e');
    }
  }
}
