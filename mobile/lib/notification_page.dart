import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'message_page.dart';
import 'bookmark_page.dart';
import 'profile_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  final String profileImage = 'images/me.jpg';

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
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
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
        body: TabBarView(
          children: [
            _buildNotificationList("all"),
            _buildNotificationList("verified"),
            _buildNotificationList("mentions"),
            _buildNotificationList("replies"),
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
                              onPressed: () {},
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TabBar(
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
                    child: TabBarView(
                      children: [
                        _buildNotificationList("all"),
                        _buildNotificationList("verified"),
                        _buildNotificationList("mentions"),
                        _buildNotificationList("replies"),
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

  Widget _buildNotificationList(String type) {
    // Different data based on type
    List<Map<String, dynamic>> notifications = [
      {
        'type': 'like',
        'user': 'John Doe',
        'username': '@johndoe',
        'profileImage': 'images/user1.jpg',
        'content': 'Menyukai postingan Anda',
        'time': '2j',
        'postContent': 'Flutter is amazing for cross-platform development!',
      },
      {
        'type': 'retweet',
        'user': 'Jane Smith',
        'username': '@janesmith',
        'profileImage': 'images/user2.jpg',
        'content': 'Meretweet postingan Anda',
        'time': '4j',
        'postContent': 'Learning Dart is fun and productive!',
      },
      {
        'type': 'follow',
        'user': 'Bob Johnson',
        'username': '@bobjohnson',
        'profileImage': 'images/user3.jpg',
        'content': 'Mulai mengikuti Anda',
        'time': '1h',
      },
      {
        'type': 'mention',
        'user': 'Alice Williams',
        'username': '@alicewilliams',
        'profileImage': 'images/user4.jpg',
        'content': 'Menyebut Anda dalam postingan',
        'time': '5j',
        'postContent': 'Hey @yourhandle, check out this Flutter tutorial!',
      },
      {
        'type': 'reply',
        'user': 'Charlie Brown',
        'username': '@charliebrown',
        'profileImage': 'images/user5.jpg',
        'content': 'Membalas postingan Anda',
        'time': '3j',
        'postContent': 'Absolutely! Flutter is the future of mobile development.',
        'originalPost': 'Flutter is amazing for cross-platform development!',
      },
    ];

    // Filter based on type
    if (type != "all") {
      if (type == "verified") {
        // Just a sample filter for demo purposes
        notifications = notifications.take(2).toList();
      } else if (type == "mentions") {
        notifications = notifications.where((n) => n['type'] == 'mention').toList();
      } else if (type == "replies") {
        notifications = notifications.where((n) => n['type'] == 'reply').toList();
      }
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    IconData iconData;
    Color iconColor;
    
    // Set icon based on notification type
    switch (notification['type']) {
      case 'like':
        iconData = Icons.favorite;
        iconColor = Colors.pink;
        break;
      case 'retweet':
        iconData = Icons.repeat;
        iconColor = Colors.green;
        break;
      case 'follow':
        iconData = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case 'mention':
        iconData = Icons.alternate_email;
        iconColor = Colors.blue;
        break;
      case 'reply':
        iconData = Icons.reply;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
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
            child: Icon(iconData, color: iconColor),
          ),
          
          // Profile image
          CircleAvatar(
            backgroundImage: AssetImage(notification['profileImage']),
            radius: 20,
          ),
          
          SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info
                Row(
                  children: [
                    Text(
                      notification['user'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4),
                    Text(
                      notification['username'],
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '· ${notification['time']}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                
                SizedBox(height: 4),
                
                // Notification message
                Text(
                  notification['content'],
                  style: TextStyle(color: Colors.grey),
                ),
                
                // Post content if exists
                if (notification.containsKey('postContent'))
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(notification['postContent']),
                  ),
                
                // Original post for replies
                if (notification.containsKey('originalPost'))
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Membalas postingan Anda:',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(notification['originalPost']),
                      ],
                    ),
                  ),
                
                // Follow button for follow notifications
                if (notification['type'] == 'follow')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Ikuti Balik'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNav(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
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
          
          // Home
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
          
          // Explore
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
          
          // Notifications
          _buildNavButton(
            icon: Icons.notifications_outlined,
            isActive: true,
            onTap: () {
              // Already on Notifications page
            },
          ),
          const SizedBox(height: 22),
          
          // Messages
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
          
          // Bookmarks
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
          
          // Profile
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
          const SizedBox(height: 22),
          
          // More
          _buildNavButton(
            icon: Icons.more_horiz,
            isActive: false,
            onTap: () {
              // Show more options menu
            },
          ),
          const SizedBox(height: 20),
          
          // Post button
          ElevatedButton(
            onPressed: () {
              // Show post dialog
            },
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
          
          // Profile avatar
          GestureDetector(
            onTap: () {
              // Show profile menu
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(profileImage),
            ),
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
              onPressed: () {
                // Navigate to Trends page
              },
            ),
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.notifications_outlined, color: Colors.blue, size: 26),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                // Already on Notifications page
              },
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
                'Dapatkan fitur-fitur eksklusif dengan berlangganan Premium.',
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
        
        // Who to follow
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Untuk Diikuti',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              _buildFollowSuggestion(
                'Flutter Dev', 
                '@flutterdev', 
                'images/user1.jpg'
              ),
              Divider(color: Colors.grey[800], height: 16),
              _buildFollowSuggestion(
                'Dart Lang', 
                '@dart_lang', 
                'images/user2.jpg'
              ),
              Divider(color: Colors.grey[800], height: 16),
              _buildFollowSuggestion(
                'Android Dev', 
                '@AndroidDev', 
                'images/user3.jpg'
              ),
              SizedBox(height: 16),
              Text(
                'Tampilkan lebih banyak',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowSuggestion(String name, String username, String image) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(image),
          radius: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                username,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text('Ikuti'),
        ),
      ],
    );
  }
}