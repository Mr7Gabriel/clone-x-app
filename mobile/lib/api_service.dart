import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; 
import 'package:http_parser/http_parser.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
      ),
    );
  }

  // Base URL for your backend server
  static const String baseUrl = 'http://localhost:3000/api';

  String? _authToken;
  late Dio _dio;

  // Get stored auth token
  Future<String?> _getAuthToken() async {
    if (_authToken != null) return _authToken;

    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  // Save auth token
  Future<void> _saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear auth token
  Future<void> _clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders({bool needsAuth = false}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (needsAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle API response
  Map<String, dynamic>? _handleResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print('Error parsing JSON: $e');
        return null;
      }
    } else {
      print('API Error ${response.statusCode}: ${response.body}');
      return null;
    }
  }

  // =================== TOKEN METHODS ============================
  Future<String?> getStoredToken() async {
    return await _getAuthToken();
  }

  // =================== HELPER METHODS ==================
  Future<bool> validateImageFile(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        return false;
      }

      // Check file size (max 10MB)
      final fileSizeInBytes = await imageFile.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 10) {
        return false;
      }

      // Check file extension
      final extension = imageFile.path.toLowerCase().split('.').last;
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
      if (!allowedExtensions.contains(extension)) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }

  // =================== AUTHENTICATION METHODS ===================

  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: json.encode({'username': username, 'password': password}),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        await _saveAuthToken(data['token']);
        return User.fromMap(data['user']);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<User?> register(
    String username,
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        await _saveAuthToken(data['token']);
        return User.fromMap(data['user']);
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _clearAuthToken();
  }

  // =================== FILE UPLOAD METHODS ===================

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      FormData formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '/upload/profile-image',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['image_url'];
      }
      return null;
    } catch (e) {
      print('Upload profile image error: $e');
      return null;
    }
  }

  Future<String?> uploadBannerImage(File imageFile) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      FormData formData = FormData.fromMap({
        'bannerImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '/upload/banner-image',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['image_url'];
      }
      return null;
    } catch (e) {
      print('Upload banner image error: $e');
      return null;
    }
  }
  // =================== POST METHODS ===================

    Future<String?> uploadPostImage(File imageFile) async {
  try {
    // Check if file exists and is readable
    if (!await imageFile.exists()) {
      throw Exception('Image file does not exist');
    }

    // Check file size (max 10MB)
    final fileSizeInBytes = await imageFile.length();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    if (fileSizeInMB > 10) {
      throw Exception('Image file is too large (max 10MB)');
    }

    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    FormData formData = FormData.fromMap({
      'postImage': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'post_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    });

    print('Uploading image: ${imageFile.path}');
    print('File size: ${fileSizeInMB.toStringAsFixed(2)}MB');

    final response = await _dio.post(
      '/upload/post-image',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    print('Upload response status: ${response.statusCode}');
    print('Upload response body: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['image_url'];
    } else {
      throw Exception('Invalid response format');
    }
  } catch (e) {
    print('Error uploading image: $e');
    throw Exception('Upload failed: $e');
  }
}

  Future<String?> uploadPostImageWeb(XFile imageFile) async {
  try {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    // Baca file sebagai bytes
    final Uint8List bytes = await imageFile.readAsBytes();
    print('DEBUG WEB: Image bytes length: ${bytes.length}');
    
    if (bytes.isEmpty) {
      throw Exception('Image file is empty');
    }

    // Check file size (max 10MB)
    final fileSizeInMB = bytes.length / (1024 * 1024);
    if (fileSizeInMB > 10) {
      throw Exception('Image file is too large (max 10MB)');
    }

    // Buat FormData dengan bytes
    FormData formData = FormData.fromMap({
      'postImage': MultipartFile.fromBytes(
        bytes,
        filename: 'post_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    print('DEBUG WEB: Uploading image...');
    print('DEBUG WEB: File size: ${fileSizeInMB.toStringAsFixed(2)}MB');
    
    final response = await _dio.post(
      '/upload/post-image',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    print('DEBUG WEB: Upload response status: ${response.statusCode}');
    print('DEBUG WEB: Upload response body: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['image_url'];
    } else {
      throw Exception('Upload failed: ${response.data}');
    }
  } catch (e) {
    print('ERROR WEB: Upload failed: $e');
    throw Exception('Web upload failed: $e');
  }
}

  Future<String?> uploadPostImageFromXFile(XFile imageFile) async {
  if (kIsWeb) {
    return uploadPostImageWeb(imageFile);
  } else {
    // Untuk mobile, convert XFile ke File
    final File file = File(imageFile.path);
    return uploadPostImage(file);
  }
}


  Future<List<Post>> getPosts({int limit = 20, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts?limit=$limit&offset=$offset'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final postsData = data['posts'] as List;
        return postsData.map((postData) => Post.fromMap(postData)).toList();
      }
      return [];
    } catch (e) {
      print('Get posts error: $e');
      return [];
    }
  }

  Future<Post?> createPost(String content, {String? imageUrl}) async {
  try {
    // PERBAIKAN: Validasi content tidak boleh kosong
    String finalContent = content.trim();
    if (finalContent.isEmpty && imageUrl != null) {
      finalContent = "📷"; // Default content untuk post dengan gambar saja
    }
    
    if (finalContent.isEmpty && imageUrl == null) {
      throw Exception('Content atau image harus ada');
    }
    
    print('DEBUG API: Creating post with content: "$finalContent"');
    print('DEBUG API: Image URL: $imageUrl');
    
    // Buat body request
    Map<String, dynamic> requestBody = {
      'content': finalContent,
    };
    
    // Tambahkan image_url jika ada
    if (imageUrl != null && imageUrl.isNotEmpty) {
      requestBody['image_url'] = imageUrl;
    }
    
    print('DEBUG API: Request body: $requestBody');
    
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: await _getHeaders(needsAuth: true),
      body: json.encode(requestBody),
    );

    print('DEBUG API: Response status: ${response.statusCode}');
    print('DEBUG API: Response body: ${response.body}');

    final data = _handleResponse(response);
    if (data != null && data['success'] == true) {
      return Post.fromMap(data['post']);
    }
    
    // Jika gagal, throw error dengan pesan yang lebih detail
    if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Bad request');
    }
    
    return null;
  } catch (e) {
    print('Create post error: $e');
    rethrow; // Re-throw agar error bisa ditangkap di caller
  }
}

  Future<bool> likePost(int postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return data['liked'] ?? false;
      }
      return false;
    } catch (e) {
      print('Like post error: $e');
      return false;
    }
  }

  Future<bool> retweetPost(int postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/retweet'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return data['retweeted'] ?? false;
      }
      return false;
    } catch (e) {
      print('Retweet post error: $e');
      return false;
    }
  }

  Future<Reply?> replyToPost(
    int postId,
    String content, {
    String? imageUrl,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/replies'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'content': content,
          if (imageUrl != null) 'image_url': imageUrl,
        }),
      );

      print('Reply response status: ${response.statusCode}');
      print('Reply response body: ${response.body}');

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return Reply.fromMap(data['reply']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to post reply');
      }
    } catch (e) {
      print('Error posting reply: $e');
      throw Exception('Reply failed: $e');
    }
  }

  Future<List<Reply>> getReplies(int postId) async {
    try {
      print('=== DEBUG getReplies ===');
      print('Post ID: $postId');
      print('API URL: $baseUrl/posts/$postId/replies');

      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/replies'),
        headers: await _getHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.body.length}');

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final repliesData = data['replies'] as List;
        print('Raw replies data count: ${repliesData.length}');

        List<Reply> replies = [];
        for (int i = 0; i < repliesData.length; i++) {
          try {
            final reply = Reply.fromMap(repliesData[i]);
            replies.add(reply);
            print('Successfully parsed reply $i: ${reply.content}');
          } catch (e) {
            print('Failed to parse reply $i: $e');
            print('Reply data: ${repliesData[i]}');
            // Skip yang error, jangan stop seluruh proses
            continue;
          }
        }

        print('Final parsed replies count: ${replies.length}');
        return replies;
      } else {
        print('API response unsuccessful or null');
        return [];
      }
    } catch (e, stackTrace) {
      print('Get replies error: $e');
      print('StackTrace: $stackTrace');
      return [];
    }
  }

  // =================== USER METHODS ===================

  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?q=$query'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final usersData = data['users'] as List;
        return usersData.map((userData) => User.fromMap(userData)).toList();
      }
      return [];
    } catch (e) {
      print('Search users error: $e');
      return [];
    }
  }

  Future<User?> getUserById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return User.fromMap(data['user']);
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/username/$username'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return User.fromMap(data['user']);
      }
      return null;
    } catch (e) {
      print('Get user by username error: $e');
      return null;
    }
  }

  Future<User?> updateUserProfile(
    int userId, {
    String? name,
    String? bio,
    String? location,
    String? website,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'name': name,
          'bio': bio,
          'location': location,
          'website': website,
        }),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return User.fromMap(data['user']);
      }
      return null;
    } catch (e) {
      print('Update user profile error: $e');
      return null;
    }
  }

  Future<List<Post>> getUserPosts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/posts'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final postsData = data['posts'] as List;
        return postsData.map((postData) => Post.fromMap(postData)).toList();
      }
      return [];
    } catch (e) {
      print('Get user posts error: $e');
      return [];
    }
  }

  // =================== FOLLOW METHODS ===================

  Future<bool> followUser(int followingId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$followingId/follow'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return data['following'] ?? false;
      }
      return false;
    } catch (e) {
      print('Follow user error: $e');
      return false;
    }
  }

  Future<bool> isFollowing(int followingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$followingId/is-following'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return data['following'] ?? false;
      }
      return false;
    } catch (e) {
      print('Check following error: $e');
      return false;
    }
  }

  Future<List<User>> getFollowers(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/followers'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final usersData = data['followers'] as List;
        return usersData.map((userData) => User.fromMap(userData)).toList();
      }
      return [];
    } catch (e) {
      print('Get followers error: $e');
      return [];
    }
  }

  Future<List<User>> getFollowing(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/following'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final usersData = data['following'] as List;
        return usersData.map((userData) => User.fromMap(userData)).toList();
      }
      return [];
    } catch (e) {
      print('Get following error: $e');
      return [];
    }
  }

  // =================== BOOKMARK METHODS ===================

  Future<bool> bookmarkPost(int postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/bookmark'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return data['bookmarked'] ?? false;
      }
      return false;
    } catch (e) {
      print('Bookmark post error: $e');
      return false;
    }
  }

  Future<List<Post>> getBookmarks(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/bookmarks'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final postsData = data['bookmarks'] as List;
        return postsData.map((postData) => Post.fromMap(postData)).toList();
      }
      return [];
    } catch (e) {
      print('Get bookmarks error: $e');
      return [];
    }
  }

  Future<bool> isBookmarked(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/is-bookmarked'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return data['bookmarked'] ?? false;
      }
      return false;
    } catch (e) {
      print('Check bookmark error: $e');
      return false;
    }
  }

  // =================== NOTIFICATION METHODS ===================

  Future<List<XNotification>> getNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/notifications'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final notificationsData = data['notifications'] as List;
        return notificationsData
            .map((notificationData) => XNotification.fromMap(notificationData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get notifications error: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: await _getHeaders(needsAuth: true),
      );
    } catch (e) {
      print('Mark notification read error: $e');
    }
  }

  Future<int> getUnreadNotificationCount(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/notifications/unread-count'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Get unread notification count error: $e');
      return 0;
    }
  }

  // =================== MESSAGE METHODS ===================

  Future<List<Message>> getMessages(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/messages'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final messagesData = data['messages'] as List;
        return messagesData
            .map((messageData) => Message.fromMap(messageData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get messages error: $e');
      return [];
    }
  }

  Future<List<Message>> getConversationMessages(
    int userId,
    int otherUserId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/messages/$otherUserId'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final messagesData = data['messages'] as List;
        return messagesData
            .map((messageData) => Message.fromMap(messageData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get conversation messages error: $e');
      return [];
    }
  }

  Future<Message?> sendMessage(int receiverId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({'receiver_id': receiverId, 'content': content}),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return Message.fromMap(data['message']);
      }
      return null;
    } catch (e) {
      print('Send message error: $e');
      return null;
    }
  }

  // =================== TRENDING/EXPLORE METHODS ===================

  Future<List<String>> getTrendingTopics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trending'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final trendsData = data['trends'] as List;
        return trendsData.cast<String>();
      }
      return [];
    } catch (e) {
      print('Get trending topics error: $e');
      return [];
    }
  }

  Future<List<User>> getSuggestedUsers(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/suggestions'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final usersData = data['suggestions'] as List;
        return usersData.map((userData) => User.fromMap(userData)).toList();
      }
      return [];
    } catch (e) {
      print('Get suggested users error: $e');
      return [];
    }
  }

  // =================== HEALTH CHECK ===================

  Future<bool> isServerHealthy() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      return data != null && data['success'] == true;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }
}
