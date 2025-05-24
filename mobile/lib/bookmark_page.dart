import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'notification_page.dart';
import 'message_page.dart';
import 'profile_page.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({Key? key}) : super(key: key);

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
        title: Text('Bookmark'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showBookmarkOptions(context);
            },
          ),
        ],
      ),
      body: _buildBookmarkContent(),
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
          
          // Main content
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bookmark',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '@yourusername',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          _showBookmarkOptions(context);
                        },
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: _buildBookmarkContent(),
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
    );
  }

  void _showBookmarkOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.white),
                title: Text('Hapus semua Bookmark', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Handle delete all bookmarks
                },
              ),
              ListTile(
                leading: Icon(Icons.folder_outlined, color: Colors.white),
                title: Text('Tambahkan Bookmark ke daftar', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Handle add bookmarks to list
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.white),
                title: Text('Bagikan Bookmark', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Handle share bookmarks
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookmarkContent() {
    // Sample bookmark posts
    List<Map<String, dynamic>> bookmarks = [
      {
        'username': 'Flutter',
        'handle': '@flutterdev',
        'content': 'Introducing the latest features in Flutter 3.0! Check out our blog for more details.',
        'timestamp': '2d',
        'profileImage': 'images/user1.jpg',
        'isVerified': true,
        'likes': 1253,
        'retweets': 421,
        'replies': 89,
      },
      {
        'username': 'Google Developers',
        'handle': '@googledevs',
        'content': 'Join us for Google I/O next month where we\'ll announce exciting new developer tools and features!',
        'timestamp': '3d',
        'profileImage': 'images/user2.jpg',
        'isVerified': true,
        'likes': 3521,
        'retweets': 1025,
        'replies': 348,
        'imageUrl': 'images/google_io.jpg',
      },
      {
        'username': 'Android Developers',
        'handle': '@AndroidDev',
        'content': 'Learn how to optimize your Android app performance with these tips and tricks from our engineering team.',
        'timestamp': '5d',
        'profileImage': 'images/user3.jpg',
        'isVerified': true,
        'likes': 892,
        'retweets': 314,
        'replies': 67,
      },
    ];

    return bookmarks.isEmpty
        ? _buildEmptyBookmarkState()
        : ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return _buildBookmarkItem(bookmark);
            },
          );
  }

  Widget _buildEmptyBookmarkState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Belum ada Bookmark',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Ketuk ikon bookmark pada postingan untuk menambahkan ke daftar favorit.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkItem(Map<String, dynamic> bookmark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(bookmark['profileImage']),
                radius: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bookmark['username'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (bookmark['isVerified'])
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.verified, color: Colors.blue, size: 16),
                          ),
                        SizedBox(width: 4),
                        Text(
                          bookmark['handle'],
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          ' · ${bookmark['timestamp']}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(bookmark['content']),
                    if (bookmark.containsKey('imageUrl')) ...[
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          bookmark['imageUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    SizedBox(height: 12),
                    // Interaction icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInteractionIcon(
                          icon: Icons.chat_bubble_outline,
                          count: bookmark['replies'],
                        ),
                        _buildInteractionIcon(
                          icon: Icons.repeat,
                          count: bookmark['retweets'],
                        ),
                        _buildInteractionIcon(
                          icon: Icons.favorite_border,
                          count: bookmark['likes'],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.bookmark,
                              color: Colors.blue,
                              size: 16,
                            ),
                            IconButton(
                              icon: Icon(Icons.share_outlined, color: Colors.grey, size: 16),
                              onPressed: () {},
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionIcon({required IconData icon, required int count}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
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
            isActive: true,
            onTap: () {
              // Already on Bookmarks page
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