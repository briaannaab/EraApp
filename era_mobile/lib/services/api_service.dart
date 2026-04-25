import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://improved-giggle-4qwv56rvwgrf9vg-8000.app.github.dev';

class ApiService {
  static Future<List<dynamic>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load posts');
  }

  static Future<Map<String, dynamic>> createPost({
    required int userId,
    required String username,
    required String content,
    List<String> tags = const [],
    String? mediaUrl,
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
      print('Upload status: ${response.statusCode}');
      print('Upload body: $body');
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }