import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'message_page.dart';
import 'bookmark_page.dart';
import 'profile_page.dart';
import 'user_provider.dart';
import 'models.dart';
import 'api_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  List<XNotification> _allNotifications = [];
  List<XNotification> _verifiedNotifications = [];
  List<XNotification> _mentionNotifications = [];
  List<XNotification> _replyNotifications = [];
  
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser != null) {
        final notifications = await _apiService.getNotifications(currentUser.id);
        
        setState(() {
          _allNotifications = notifications;
          _verifiedNotifications = notifications.where((n) => n.actorIsVerified == true).toList();
          _mentionNotifications = notifications.where((n) => n.type == 'mention').toList();
          _replyNotifications = notifications.where((n) => n.type == 'reply').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshNotifications();
      await _loadNotifications();
    } catch (e) {
      print('Error refreshing notifications: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _markAsRead(XNotification notification) async {
    if (!notification.isRead) {
      try {
        await _apiService.markNotificationAsRead(notification.id);
        setState(() {
          // Update local state
          final index = _allNotifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _allNotifications[index] = XNotification(
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
          }
        });
      } catch (e) {
        print('Error marking notification as read: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return _buildMobileLayout(context);
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text('Notifikasi'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings_outlined),
              onPressed: () => _showNotificationSettings(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: "Semua"),
              Tab(text: "Terverifikasi"),
              Tab(text: "Sebutan"),
              Tab(text: "Balasan"),
            ],
            indicatorColor: Colors.blue,
          ),
        ),
        body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(_allNotifications),
                _buildNotificationList(_verifiedNotifications),
                _buildNotificationList(_mentionNotifications),
                _buildNotificationList(_replyNotifications),
              ],
            ),
        bottomNavigationBar: _buildMobileBottomNav(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            // Side Navigation
            _buildSideNav(context),
            
            // Main content
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Header with tabs
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notifikasi',
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.settings_outlined),
                              onPressed: () => _showNotificationSettings(),
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabs: [
                            Tab(text: "Semua"),
                            Tab(text: "Terverifikasi"),
                            Tab(text: "Sebutan"),
                            Tab(text: "Balasan"),
                          ],
                          indicatorColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  
                  // Notification content
                  Expanded(
                    child: _isLoading 
                      ? Center(child: CircularProgressIndicator(color: Colors.blue))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildNotificationList(_allNotifications),
                            _buildNotificationList(_verifiedNotifications),
                            _buildNotificationList(_mentionNotifications),
                            _buildNotificationList(_replyNotifications),
                          ],
                        ),
                  ),
                ],
              ),
            ),
            
            // Right sidebar if enough space
            if (MediaQuery.of(context).size.width > 1000)
              Container(
                width: 350,
                child: _buildRightSidebar(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<XNotification> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      color: Colors.blue,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Ketika seseorang berinteraksi dengan Anda, notifikasi akan muncul di sini.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(XNotification notification) {
    IconData iconData;
    Color iconColor;
    String actionText;
    
    // Set icon and text based on notification type
    switch (notification.type) {
      case 'like':
        iconData = Icons.favorite;
        iconColor = Colors.pink;
        actionText = 'menyukai postingan Anda';
        break;
      case 'retweet':
        iconData = Icons.repeat;
        iconColor = Colors.green;
        actionText = 'meretweet postingan Anda';
        break;
      case 'follow':
        iconData = Icons.person_add;
        iconColor = Colors.blue;
        actionText = 'mulai mengikuti Anda';
        break;
      case 'mention':
        iconData = Icons.alternate_email;
        iconColor = Colors.blue;
        actionText = 'menyebut Anda dalam postingan';
        break;
      case 'reply':
        iconData = Icons.reply;
        iconColor = Colors.orange;
        actionText = 'membalas postingan Anda';
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.blue;
        actionText = 'berinteraksi dengan Anda';
    }

    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : Colors.blue.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            
            // Profile image
            CircleAvatar(
              backgroundImage: notification.actorProfileImage != null
                  ? NetworkImage('http://localhost:3000/${notification.actorProfileImage}')
                  : AssetImage('images/default_avatar.jpg') as ImageProvider,
              radius: 16,
            ),
            
            SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info and action
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      children: [
                        TextSpan(
                          text: notification.actorName ?? 'Unknown User',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (notification.actorIsVerified == true)
                          WidgetSpan(
                            child: Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified, color: Colors.blue, size: 16),
                            ),
                          ),
                        TextSpan(text: ' $actionText'),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  
                  // Time
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  
                  // Post content if exists
                  if (notification.content != null && notification.content!.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        notification.content!,
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ),
                  
                  // Follow button for follow notifications
                  if (notification.type == 'follow')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        onPressed: () => _followUser(notification.actorId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text('Ikuti Balik'),
                      ),
                    ),
                ],
              ),
            ),
            
            // Read indicator
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(XNotification notification) async {
    // Mark as read
    await _markAsRead(notification);
    
    // Navigate based on notification type
    switch (notification.type) {
      case 'follow':
        // Navigate to user profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(userId: notification.actorId),
          ),
        );
        break;
      case 'like':
      case 'retweet':
      case 'reply':
      case 'mention':
        // Navigate to post detail (if postId exists)
        if (notification.postId != null) {
          _showPostDetail(notification.postId!);
        }
        break;
    }
  }

  Future<void> _followUser(int userId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.followUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil mengikuti pengguna!')),
      );
    } catch (e) {
      print('Error following user: $e');
    }
  }

  void _showPostDetail(int postId) {
    // Navigate to post detail or show in dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to post $postId')),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.mark_email_read, color: Colors.white),
                title: Text('Tandai semua sebagai dibaca', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _markAllAsRead();
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text('Pengaturan notifikasi', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showNotificationPreferences();
                },
              ),
              ListTile(
                leading: Icon(Icons.filter_list, color: Colors.white),
                title: Text('Filter notifikasi', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showNotificationFilters();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      // Mark all unread notifications as read
      final unreadNotifications = _allNotifications.where((n) => !n.isRead).toList();
      
      for (final notification in unreadNotifications) {
        await _apiService.markNotificationAsRead(notification.id);
      }
      
      // Refresh notifications
      await _loadNotifications();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua notifikasi telah ditandai sebagai dibaca')),
      );
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  void _showNotificationPreferences() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Pengaturan Notifikasi', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Notifikasi Push', style: TextStyle(color: Colors.white)),
                value: true,
                onChanged: (value) {
                  // Handle push notification setting
                },
                activeColor: Colors.blue,
              ),
              SwitchListTile(
                title: Text('Email Notifikasi', style: TextStyle(color: Colors.white)),
                value: false,
                onChanged: (value) {
                  // Handle email notification setting
                },
                activeColor: Colors.blue,
              ),
              SwitchListTile(
                title: Text('Notifikasi Like', style: TextStyle(color: Colors.white)),
                value: true,
                onChanged: (value) {
                  // Handle like notification setting
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationFilters() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Filter Notifikasi', style: TextStyle(color: Colors.white)),
          content: Text(
            'Fitur filter notifikasi akan segera tersedia.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSideNav(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Logo
          SvgPicture.asset(
            'images/x_logo_2023.png',
            width: 30,
            color: Colors.white,
          ),
          const SizedBox(height: 22),
          
          _buildNavButton(
            icon: Icons.home,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => HomeScreen())
              );
            },
          ),
          const SizedBox(height: 22),
          
          _buildNavButton(
            icon: Icons.search,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => ExplorePage())
              );
            },
          ),
          const SizedBox(height: 22),
          
          _buildNavButton(
            icon: Icons.notifications_outlined,
            isActive: true,
            onTap: () {},
          ),
          const SizedBox(height: 22),
          
          _buildNavButton(
            icon: Icons.mail_outline,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => MessagePage())
              );
            },
          ),
          const SizedBox(height: 22),
          
          _buildNavButton(
            icon: Icons.bookmark_border,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => BookmarkPage())
              );
            },
          ),
          const SizedBox(height: 22),
          
          _buildNavButton(
            icon: Icons.person_outline,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => ProfilePage())
              );
            },
          ),
          const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: Size(60, 60),
              padding: EdgeInsets.zero,
            ),
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
          
          const Spacer(),
          
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.currentUser;
              return CircleAvatar(
                radius: 18,
                backgroundImage: user?.profileImage != null 
                  ? NetworkImage('http://localhost:3000/${user!.profileImage}')
                  : AssetImage('images/default_avatar.jpg') as ImageProvider,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Center(
          child: Icon(
            icon, 
            color: isActive ? Colors.blue : Colors.grey,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBottomNav(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.grey, size: 26),
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => HomeScreen())
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.grey, size: 26),
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => ExplorePage())
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.show_chart, color: Colors.grey, size: 26),
              onPressed: () {},
            ),
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.notifications_outlined, color: Colors.blue, size: 26),
                  if (_allNotifications.any((n) => !n.isRead))
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.mail_outline, color: Colors.grey, size: 26),
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => MessagePage())
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Column(
      children: [
        // Unread count widget
        if (_allNotifications.any((n) => !n.isRead))
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi Belum Dibaca',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '${_allNotifications.where((n) => !n.isRead).length} notifikasi baru',
                  style: TextStyle(color: Colors.blue),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _markAllAsRead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Tandai Semua Dibaca'),
                ),
              ],
            ),
          ),
        
        // Premium Box
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Berlangganan Premium',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Dapatkan notifikasi prioritas dan fitur eksklusif lainnya.',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Berlangganan'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'baru saja';
    }
  }
}