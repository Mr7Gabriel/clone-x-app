import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'notification_page.dart';
import 'bookmark_page.dart';
import 'profile_page.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Text('Pesan'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.settings_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari Direct Messages",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          
          // Messages List
          Expanded(
            child: _buildMessageList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new message
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add_comment, color: Colors.white),
      ),
      bottomNavigationBar: _buildMobileBottomNav(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Side Navigation
          _buildSideNav(context),
          
          // Messages Panel
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Messages Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pesan',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.settings_outlined),
                            onPressed: () {},
                            color: Colors.white,
                          ),
                          IconButton(
                            icon: Icon(Icons.add_comment),
                            onPressed: () {
                              // Create new message
                            },
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Search Messages
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari Direct Messages",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                
                // Messages List
                Expanded(
                  child: _buildMessageList(),
                ),
              ],
            ),
          ),
          
          // Selected conversation or welcome screen
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[800]!, width: 0.5),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      'Pesan Anda',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Kirim, terima, dan arsipkan Direct Messages kamu.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text('Tulis Pesan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    // Sample message data
    List<Map<String, dynamic>> messages = [
      {
        'user': 'John Doe',
        'username': '@johndoe',
        'profileImage': 'images/user1.jpg',
        'lastMessage': 'Hey, how are you doing?',
        'time': '2j',
        'isVerified': true,
      },
      {
        'user': 'Flutter Team',
        'username': '@flutterdev',
        'profileImage': 'images/user2.jpg',
        'lastMessage': 'Check out our latest release with exciting new features!',
        'time': '5j',
        'isVerified': true,
      },
      {
        'user': 'Jane Smith',
        'username': '@janesmith',
        'profileImage': 'images/user3.jpg',
        'lastMessage': 'Did you see that new Flutter plugin?',
        'time': '1h',
        'isVerified': false,
      },
      {
        'user': 'Tech News',
        'username': '@technews',
        'profileImage': 'images/user4.jpg',
        'lastMessage': 'Breaking: Google announces new Flutter widgets',
        'time': '2h',
        'isVerified': true,
      },
      {
        'user': 'Bob Johnson',
        'username': '@bobjohnson',
        'profileImage': 'images/user5.jpg',
        'lastMessage': 'Let\'s catch up this weekend!',
        'time': '1d',
        'isVerified': false,
      },
    ];

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
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
          CircleAvatar(
            backgroundImage: AssetImage(message['profileImage']),
            radius: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            message['user'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (message['isVerified'])
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified, color: Colors.blue, size: 16),
                            ),
                          SizedBox(width: 4),
                          Text(
                            message['username'],
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      message['time'],
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  message['lastMessage'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[400]),
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
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => NotificationPage())
              );
            },
          ),
          const SizedBox(height: 22),
          
          // Messages
          _buildNavButton(
            icon: Icons.mail_outline,
            isActive: true,
            onTap: () {
              // Already on Messages page
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
                // Show Trends
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.grey, size: 26),
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => NotificationPage())
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.mail_outline, color: Colors.blue, size: 26),
              onPressed: () {
                // Already on Messages page
              },
            ),
          ],
        ),
      ),
    );
  }
}