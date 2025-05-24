import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Base URL for your backend server
  static const String baseUrl = 'http://localhost:3000/api';
  
  String? _authToken;

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
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      print('API Error ${response.statusCode}: ${response.body}');
      return null;
    }
  }

  // Authentication Methods
  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
          'password': password,
        }),
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

  Future<User?> register(String username, String email, String password, String name) async {
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

  // Post Methods
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

  Future<Post?> createPost(int userId, String content, {String? imageUrl}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'content': content,
          'image_url': imageUrl,
        }),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return Post.fromMap(data['post']);
      }
      return null;
    } catch (e) {
      print('Create post error: $e');
      return null;
    }
  }

  Future<bool> likePost(int userId, int postId) async {
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

  Future<bool> retweetPost(int userId, int postId) async {
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

  Future<Reply?> replyToPost(int userId, int postId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/replies'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'content': content,
        }),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        return Reply.fromMap(data['reply']);
      }
      return null;
    } catch (e) {
      print('Reply post error: $e');
      return null;
    }
  }

  Future<List<Reply>> getReplies(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/replies'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final repliesData = data['replies'] as List;
        return repliesData.map((replyData) => Reply.fromMap(replyData)).toList();
      }
      return [];
    } catch (e) {
      print('Get replies error: $e');
      return [];
    }
  }

  // User Methods
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

  // Follow Methods
  Future<bool> followUser(int followerId, int followingId) async {
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

  Future<bool> isFollowing(int followerId, int followingId) async {
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

  // Bookmark Methods
  Future<bool> bookmarkPost(int userId, int postId) async {
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

  Future<bool> isBookmarked(int userId, int postId) async {
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

  // Notification Methods
  Future<List<XNotification>> getNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/notifications'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final notificationsData = data['notifications'] as List;
        return notificationsData.map((notificationData) => XNotification.fromMap(notificationData)).toList();
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

  // Message Methods
  Future<List<Message>> getMessages(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/messages'),
        headers: await _getHeaders(needsAuth: true),
      );

      final data = _handleResponse(response);
      if (data != null && data['success'] == true) {
        final messagesData = data['messages'] as List;
        return messagesData.map((messageData) => Message.fromMap(messageData)).toList();
      }
      return [];
    } catch (e) {
      print('Get messages error: $e');
      return [];
    }
  }

  Future<Message?> sendMessage(int senderId, int receiverId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: await _getHeaders(needsAuth: true),
        body: json.encode({
          'receiver_id': receiverId,
          'content': content,
        }),
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

  // Trending/Explore Methods
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

  // Health check
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