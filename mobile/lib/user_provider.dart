import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'api_service.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  List<Post> _posts = [];
  List<XNotification> _notifications = [];
  List<Message> _messages = [];
  List<Post> _bookmarks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  List<Post> get posts => _posts;
  List<XNotification> get notifications => _notifications;
  List<Message> get messages => _messages;
  List<Post> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  final ApiService _apiService = ApiService();

  // Authentication
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final user = await _apiService.login(username, password);
      if (user != null) {
        _currentUser = user;
        await _saveUserSession(user.id);
        await loadUserData();
        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError('Invalid username or password');
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String username, String email, String password, String name) async {
    _setLoading(true);
    try {
      final user = await _apiService.register(username, email, password, name);
      if (user != null) {
        _currentUser = user;
        await _saveUserSession(user.id);
        await loadUserData();
        _setError(null);
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _posts.clear();
    _notifications.clear();
    _messages.clear();
    _bookmarks.clear();
    await _clearUserSession();
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    
    if (userId != null) {
      try {
        final user = await _apiService.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          await loadUserData();
          notifyListeners();
        } else {
          await _clearUserSession();
        }
      } catch (e) {
        print('Error checking login status: $e');
        await _clearUserSession();
      }
    }
  }

  // Data Loading
  Future<void> loadUserData() async {
    if (_currentUser == null) return;
    
    await Future.wait([
      loadPosts(),
      loadNotifications(),
      loadMessages(),
      loadBookmarks(),
    ]);
  }

  Future<void> loadPosts() async {
    try {
      _posts = await _apiService.getPosts();
      notifyListeners();
    } catch (e) {
      print('Error loading posts: $e');
    }
  }

  Future<void> loadNotifications() async {
    if (_currentUser == null) return;
    
    try {
      _notifications = await _apiService.getNotifications(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> loadMessages() async {
    if (_currentUser == null) return;
    
    try {
      _messages = await _apiService.getMessages(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> loadBookmarks() async {
    if (_currentUser == null) return;
    
    try {
      _bookmarks = await _apiService.getBookmarks(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      print('Error loading bookmarks: $e');
    }
  }

  // Post Actions
  Future<bool> createPost(String content, {String? imageUrl}) async {
    if (_currentUser == null) return false;
    
    try {
      final post = await _apiService.createPost(_currentUser!.id, content, imageUrl: imageUrl);
      if (post != null) {
        _posts.insert(0, post);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

  Future<bool> likePost(int postId) async {
    if (_currentUser == null) return false;
    
    try {
      final liked = await _apiService.likePost(_currentUser!.id, postId);
      
      // Update local post data
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = Post(
          id: post.id,
          userId: post.userId,
          content: post.content,
          imageUrl: post.imageUrl,
          likeCount: liked ? post.likeCount + 1 : post.likeCount - 1,
          retweetCount: post.retweetCount,
          replyCount: post.replyCount,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          username: post.username,
          name: post.name,
          profileImage: post.profileImage,
          isVerified: post.isVerified,
        );
        notifyListeners();
      }
      
      return liked;
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  Future<bool> retweetPost(int postId) async {
    if (_currentUser == null) return false;
    
    try {
      final retweeted = await _apiService.retweetPost(_currentUser!.id, postId);
      
      // Update local post data
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = Post(
          id: post.id,
          userId: post.userId,
          content: post.content,
          imageUrl: post.imageUrl,
          likeCount: post.likeCount,
          retweetCount: retweeted ? post.retweetCount + 1 : post.retweetCount - 1,
          replyCount: post.replyCount,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          username: post.username,
          name: post.name,
          profileImage: post.profileImage,
          isVerified: post.isVerified,
        );
        notifyListeners();
      }
      
      return retweeted;
    } catch (e) {
      print('Error retweeting post: $e');
      return false;
    }
  }

  Future<bool> replyToPost(int postId, String content) async {
    if (_currentUser == null) return false;
    
    try {
      final reply = await _apiService.replyToPost(_currentUser!.id, postId, content);
      if (reply != null) {
        // Update local post reply count
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final post = _posts[postIndex];
          _posts[postIndex] = Post(
            id: post.id,
            userId: post.userId,
            content: post.content,
            imageUrl: post.imageUrl,
            likeCount: post.likeCount,
            retweetCount: post.retweetCount,
            replyCount: post.replyCount + 1,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            username: post.username,
            name: post.name,
            profileImage: post.profileImage,
            isVerified: post.isVerified,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error replying to post: $e');
      return false;
    }
  }

  Future<bool> bookmarkPost(int postId) async {
    if (_currentUser == null) return false;
    
    try {
      final bookmarked = await _apiService.bookmarkPost(_currentUser!.id, postId);
      
      if (bookmarked) {
        // Add to bookmarks list
        final post = _posts.firstWhere((p) => p.id == postId);
        _bookmarks.insert(0, post);
      } else {
        // Remove from bookmarks list
        _bookmarks.removeWhere((post) => post.id == postId);
      }
      
      notifyListeners();
      return bookmarked;
    } catch (e) {
      print('Error bookmarking post: $e');
      return false;
    }
  }

  // User Actions
  Future<bool> followUser(int userId) async {
    if (_currentUser == null) return false;
    
    try {
      final followed = await _apiService.followUser(_currentUser!.id, userId);
      
      if (followed) {
        // Update current user's following count
        _currentUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          email: _currentUser!.email,
          name: _currentUser!.name,
          bio: _currentUser!.bio,
          location: _currentUser!.location,
          website: _currentUser!.website,
          profileImage: _currentUser!.profileImage,
          bannerImage: _currentUser!.bannerImage,
          isVerified: _currentUser!.isVerified,
          followerCount: _currentUser!.followerCount,
          followingCount: _currentUser!.followingCount + 1,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );
      } else {
        // Update current user's following count
        _currentUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          email: _currentUser!.email,
          name: _currentUser!.name,
          bio: _currentUser!.bio,
          location: _currentUser!.location,
          website: _currentUser!.website,
          profileImage: _currentUser!.profileImage,
          bannerImage: _currentUser!.bannerImage,
          isVerified: _currentUser!.isVerified,
          followerCount: _currentUser!.followerCount,
          followingCount: _currentUser!.followingCount - 1,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );
      }
      
      notifyListeners();
      return followed;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      return await _apiService.searchUsers(query);
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      return await _apiService.getUserByUsername(username);
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  Future<List<Post>> getUserPosts(int userId) async {
    try {
      return await _apiService.getUserPosts(userId);
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }

  Future<bool> isFollowing(int userId) async {
    if (_currentUser == null) return false;
    
    try {
      return await _apiService.isFollowing(_currentUser!.id, userId);
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  Future<List<User>> getFollowers(int userId) async {
    try {
      return await _apiService.getFollowers(userId);
    } catch (e) {
      print('Error getting followers: $e');
      return [];
    }
  }

  Future<List<User>> getFollowing(int userId) async {
    try {
      return await _apiService.getFollowing(userId);
    } catch (e) {
      print('Error getting following: $e');
      return [];
    }
  }

  // Message Actions
  Future<bool> sendMessage(int receiverId, String content) async {
    if (_currentUser == null) return false;
    
    try {
      final message = await _apiService.sendMessage(_currentUser!.id, receiverId, content);
      if (message != null) {
        _messages.insert(0, message);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Notification Actions
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      
      // Update local notification
      final notificationIndex = _notifications.indexWhere((n) => n.id == notificationId);
      if (notificationIndex != -1) {
        final notification = _notifications[notificationIndex];
        _notifications[notificationIndex] = XNotification(
          id: notification.id,
          userId: notification.userId,
          type: notification.type,
          actorId: notification.actorId,
          postId: notification.postId,
          content: notification.content,
          isRead: true,
          createdAt: notification.createdAt,
          actorUsername: notification.actorUsername,
          actorName: notification.actorName,
          actorProfileImage: notification.actorProfileImage,
          actorIsVerified: notification.actorIsVerified,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<int> getUnreadNotificationCount() async {
    if (_currentUser == null) return 0;
    
    try {
      return await _apiService.getUnreadNotificationCount(_currentUser!.id);
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Explore/Trending
  Future<List<String>> getTrendingTopics() async {
    try {
      return await _apiService.getTrendingTopics();
    } catch (e) {
      print('Error getting trending topics: $e');
      return [];
    }
  }

  Future<List<User>> getSuggestedUsers() async {
    if (_currentUser == null) return [];
    
    try {
      return await _apiService.getSuggestedUsers(_currentUser!.id);
    } catch (e) {
      print('Error getting suggested users: $e');
      return [];
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  Future<void> _saveUserSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  // Refresh methods
  Future<void> refreshPosts() async {
    await loadPosts();
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  Future<void> refreshMessages() async {
    await loadMessages();
  }

  Future<void> refreshBookmarks() async {
    await loadBookmarks();
  }

  Future<void> refreshAll() async {
    await loadUserData();
  }
}