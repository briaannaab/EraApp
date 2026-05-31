import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://eraapp-production.up.railway.app';

class ApiService {
  static Future<List<dynamic>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load posts');
  }

  static Future<void> followUser(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/'));
      if (response.statusCode == 200) {
        final users = jsonDecode(response.body);
        final user = (users as List).firstWhere(
          (u) => u['username'] == username,
          orElse: () => null,
        );
        if (user != null) {
          await http.post(Uri.parse('$baseUrl/users/${user["id"]}/follow?follower_id=1'));
        }
      }
    } catch (e) {
      // ignore
    }
  }

  static Future<void> likeComment(int commentId) async {
    await http.post(Uri.parse('$baseUrl/comments/$commentId/like'));
  }

  static Future<void> deletePost(int postId) async {
    await http.delete(Uri.parse('$baseUrl/posts/$postId'));
  }

  static Future<Map<String, dynamic>> createPost({
    required int userId,
    required String username,
    required String content,
    List<String> tags = const [],
    String? mediaUrl,
    String? vibe,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'username': username,
        'content': content,
        'tags': tags,
        'media_url': mediaUrl,
        'vibe': vibe,
        'is_moment': isMoment,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to create post');
  }

  static Future<void> likePost(int postId) async {
    await http.post(Uri.parse('$baseUrl/posts/$postId/like'));
  }

  static Future<String?> uploadImage(Uint8List bytes, String filename) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/media/upload/image'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return data['url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> uploadVideo(Uint8List bytes, String filename) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/media/upload/video'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return data['url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getComments(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/comments/$postId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<Map<String, dynamic>> createComment({
    required int postId,
    required int userId,
    required String username,
    required String content,
    int? parentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'post_id': postId,
        'user_id': userId,
        'username': username,
        'content': content,
        'parent_id': parentId,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<String?> uploadAudio(Uint8List bytes, String filename) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/media/upload/audio'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return data['url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> checkSubscription(String creatorUsername, int subscriberId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/check/$creatorUsername/$subscriberId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_subscribed'] ?? false;
      }
    } catch (e) {}
    return false;
  }

  static Future<void> subscribe(String creatorUsername, int subscriberId, String subscriberUsername) async {
    await http.post(
      Uri.parse('$baseUrl/subscriptions/subscribe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'subscriber_id': subscriberId,
        'subscriber_username': subscriberUsername,
        'creator_username': creatorUsername,
      }),
    );
  }

  static Future<void> unsubscribe(String creatorUsername, int subscriberId) async {
    await http.delete(
      Uri.parse('$baseUrl/subscriptions/unsubscribe/$creatorUsername/$subscriberId'),
    );
  }

  static Future<int> getSubscriberCount(String creatorUsername) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/subscribers/$creatorUsername'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['count'] ?? 0;
      }
    } catch (e) {}
    return 0;
  }

  static Future<double> getCreatorEarnings(String creatorUsername) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/creator-earnings/$creatorUsername'),
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body)['total'] ?? 0.0).toDouble();
      }
    } catch (e) {}
    return 0.0;
  }

  static Future<List<dynamic>> getMoments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/moments/'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {}
    return [];
  }
}
