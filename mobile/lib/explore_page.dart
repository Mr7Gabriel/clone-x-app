import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart';
import 'notification_page.dart';
import 'message_page.dart';
import 'bookmark_page.dart';
import 'profile_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

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
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Cari X",
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildExploreContent(),
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
                // Search header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Cari X",
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.settings_outlined),
                        onPressed: () {},
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: _buildExploreContent(),
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

  Widget _buildExploreContent() {
    // Sample explore categories with trending topics
    List<Map<String, dynamic>> exploreCategories = [
      {
        'title': 'Trending di Indonesia',
        'items': [
          {'name': 'Teknologi', 'posts': '4.512 Postingan'},
          {'name': 'Flutter', 'posts': '2.300 Postingan'},
          {'name': 'Programming', 'posts': '1.845 Postingan'},
        ]
      },
      {
        'title': 'Hiburan',
        'items': [
          {'name': 'Film Terbaru', 'posts': '10K Postingan'},
          {'name': 'Musik Hits', 'posts': '8.721 Postingan'},
          {'name': 'Anime', 'posts': '5.902 Postingan'},
        ]
      },
      {
        'title': 'Olahraga',
        'items': [
          {'name': 'Sepak Bola', 'posts': '15K Postingan'},
          {'name': 'MotoGP', 'posts': '7.234 Postingan'},
          {'name': 'NBA', 'posts': '3.567 Postingan'},
        ]
      },
    ];

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10),
      children: [
        // For you section with main trends
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Untuk Anda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Featured trend with image
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[800]!, width: 0.5),
              bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trending di Indonesia',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flutter Development',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '5.129 Postingan',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'images/flutter-logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Categories and trends
        ...exploreCategories.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  category['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...category['items'].map<Widget>((item) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trending',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              item['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              item['posts'],
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.more_horiz, color: Colors.grey),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
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
            isActive: true,
            onTap: () {
              // Already on Explore
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
              icon: Icon(Icons.search, color: Colors.blue, size: 26),
              onPressed: () {
                // Already on Explore
              },
            ),
            IconButton(
              icon: Icon(Icons.show_chart, color: Colors.grey, size: 26),
              onPressed: () {
                // Show Trends
              },
            ),
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.notifications_outlined, color: Colors.grey, size: 26),
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