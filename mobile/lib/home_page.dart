import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profile_page.dart';
import 'explore_page.dart';
import 'notification_page.dart';
import 'message_page.dart';
import 'bookmark_page.dart';

void main() {
  runApp(const XCloneApp());
}

class XCloneApp extends StatelessWidget {
  const XCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final String profileImage = 'images/me.jpg'; // Gambar profil akun kamu

  @override
  Widget build(BuildContext context) {
    // Cek lebar layar untuk menentukan layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      // Tampilan untuk mobile
      return mobileLayout(context);
    } else {
      // Tampilan untuk desktop
      return desktopLayout(context);
    }
  }

  // Layout untuk tampilan mobile - sesuai Image 2
  Widget mobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            bottom: TabBar(
              tabs: [
                Tab(text: "For you"),
                Tab(text: "Following"),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            PostListView(),
            Center(
              child: Text("Belum ada postingan di 'Following'"),
            ),
          ],
        ),
        // Bottom navigation sesuai Image 2
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.home, color: Colors.blue, size: 26),
                  onPressed: () {
                    // Sudah di Home
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.grey, size: 26),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ExplorePage(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.show_chart, color: Colors.grey, size: 26),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TrendsScreen(),
                      ),
                    );
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.mail_outline, color: Colors.grey, size: 26),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MessagePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showPostDialog(context, profileImage);
          },
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  // Layout untuk tampilan desktop - sesuai Image 1
  Widget desktopLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side navigation bar dengan fungsionalitas
            Container(
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
                  // Logo X
                  SvgPicture.asset(
                    'images/x_logo_2023.png',
                    width: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 22),
                  
                  // Home button
                  _buildSideNavButton(
                    icon: Icons.home,
                    isActive: true, // Asumsikan ini adalah halaman saat ini
                    onTap: () {
                      // Sudah di halaman home - tidak perlu navigasi
                    },
                  ),
                  const SizedBox(height: 22),
                  
                  // Search button
                  _buildSideNavButton(
                    icon: Icons.search,
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ExplorePage(), 
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  
                  // Notifications button
                  _buildSideNavButton(
                    icon: Icons.notifications_outlined,
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NotificationPage(), 
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  
                  // Messages button
                  _buildSideNavButton(
                    icon: Icons.mail_outline,
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MessagePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  
                  // Bookmarks button
                  _buildSideNavButton(
                    icon: Icons.bookmark_border,
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BookmarkPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  
                  // Profile button
                  _buildSideNavButton(
                    icon: Icons.person_outline,
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  
                  // More button
                  _buildSideNavButton(
                    icon: Icons.more_horiz,
                    isActive: false,
                    onTap: () {
                      _showMoreMenu(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Post button
                  ElevatedButton(
                    onPressed: () {
                      _showPostDialog(context, profileImage);
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
                      _showProfileMenu(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[800]!, width: 1),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(profileImage),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // Main feed section - sesuai Image 1
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[800]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: TabBar(
                      tabs: [
                        Tab(text: "Untuk Anda"),
                        Tab(text: "Mengikuti"),
                      ],
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
                  ),
                  
                  // Input posting area - sesuai Image 1
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[800]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(profileImage),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Apa yang sedang terjadi?",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Icon(Icons.image, color: Colors.blue, size: 20),
                                  const SizedBox(width: 10),
                                  Icon(Icons.gif_box, color: Colors.blue, size: 20),
                                  const SizedBox(width: 10),
                                  Icon(Icons.bar_chart, color: Colors.blue, size: 20),
                                  const SizedBox(width: 10),
                                  Icon(Icons.emoji_emotions_outlined, color: Colors.blue, size: 20),
                                  const SizedBox(width: 10),
                                  Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                                  const SizedBox(width: 10),
                                  Icon(Icons.location_on, color: Colors.grey, size: 20),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showPostDialog(context, profileImage);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text(
                                      "Posting",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Post list
                  const Expanded(
                    child: TabBarView(
                      children: [
                        PostListView(),
                        Center(
                          child: Text("Belum ada postingan di 'Mengikuti'"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Right sidebar - perbaikan agar bisa di-scroll
            if (MediaQuery.of(context).size.width > 1000)
              Container(
                width: 350,
                child: Column(
                  children: [
                    // Bagian search bar (tetap di atas)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Cari",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bagian konten yang bisa di-scroll
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Premium box
                              PremiumBox(),
                              const SizedBox(height: 16),
                              
                              // Trending section
                              TrendingWidget(),
                              const SizedBox(height: 16),
                              
                              // Other widgets
                              FollowSuggestions(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build sidenav buttons
  Widget _buildSideNavButton({
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
}

// Show more menu dialog
void _showMoreMenu(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoreMenuItem(
                'Premium', 
                Icons.workspace_premium, 
                () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PremiumScreen(),
                    ),
                  );
                }
              ),
              _buildMoreMenuItem(
                'Pengaturan dan Privasi', 
                Icons.settings, 
                () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                }
              ),
              _buildMoreMenuItem(
                'Bantuan', 
                Icons.help_outline, 
                () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpScreen(),
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Helper method to build more menu items
Widget _buildMoreMenuItem(String title, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

// Show profile menu dialog
void _showProfileMenu(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('images/me.jpg'),
                ),
                title: Text('Your Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('@yourusername', style: TextStyle(color: Colors.grey)),
                trailing: Icon(Icons.check_circle, color: Colors.blue),
              ),
              Divider(color: Colors.grey[800]),
              _buildProfileMenuItem(
                'Tambahkan akun yang ada', 
                () {
                  Navigator.pop(context);
                  // Handle add existing account
                }
              ),
              _buildProfileMenuItem(
                'Kelola Akun', 
                () {
                  Navigator.pop(context);
                  // Handle manage accounts
                }
              ),
              _buildProfileMenuItem(
                'Keluar', 
                () {
                  Navigator.pop(context);
                  // Handle logout
                  _showLogoutConfirmation(context);
                }
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Helper method to build profile menu items
Widget _buildProfileMenuItem(String title, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    ),
  );
}

// Show logout confirmation
void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Keluar dari akun Anda?', style: TextStyle(color: Colors.white)),
        content: Text('Anda dapat masuk kembali kapan saja.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle actual logout here
              // For example, navigate to login screen
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(
              //     builder: (context) => AuthPage(),
              //   ),
              // );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text('Keluar'),
          ),
        ],
      );
    },
  );
}

// Show post creation dialog
void _showPostDialog(BuildContext context, String profileImage) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  Text(
                    'Draft',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(profileImage),
                    radius: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Apa yang sedang terjadi?',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey[800]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.image, color: Colors.blue),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.gif_box, color: Colors.blue),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.poll, color: Colors.blue),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.emoji_emotions, color: Colors.blue),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.event, color: Colors.blue),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.location_on, color: Colors.blue),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle post creation
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Postingan diterbitkan!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text('Posting'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class PostListView extends StatelessWidget {
  const PostListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        PostCard(
          username: "Starfess || CEK PINNED UNTUK KIRIM MENFESS",
          handle: "@starfess",
          content:
              "Kepo dong idol kalian pernah viral karena apa guys?😭\nViral in a positive way ya yorobun. Buat seru-seruan aja, pengen kenal kehidupan fandom lain wkwk\n-star.",
          timestamp: "11j",
          profileImage: 'images/profil1.jpg',
          isVerified: true,
          showBotLabel: true,
          commentsCount: 520,
          retweetsCount: 745,
          likesCount: 9000,
          viewsText: '758rb',
        ),
        PostCard(
          username: "Indonesian Pop Base",
          handle: "@IndoPopBase",
          content: "Show your now playing 🎵",
          timestamp: "22j",
          profileImage: 'images/profil2.jpg',
          isVerified: true,
          commentsCount: 751,
          retweetsCount: 526,
          likesCount: 930,
          viewsText: '101rb',
        ),
        PostCard(
          username: "TanyarI💚",
          handle: "@tanyakanrl",
          content:
              "buat yang main semua app sosmed, bener gak gambar ini? 😅 yang cuma main X tidak usah menjawab. 💚",
          timestamp: "1 Mei",
          imageUrl: "images/postingan1.jpg",
          profileImage: 'images/profil3.jpg',
          isVerified: true,
          showBotLabel: true,
          commentsCount: 728,
          retweetsCount: 1000,
          likesCount: 21000,
          viewsText: '225rb',
        ),
        PostCard(
          username: "Western Enthusiast",
          handle: "@westenthu",
          content:
              "Kalau Belly endingnya sama Conrad, saya Nazar\n- share 3 paket soal latihan UTBK PU/PM gratis di gdrive\n- membuka kelas privat toefl/ielts gratis 3 pertemuan untuk 3 org\n- Membagikan materi biologi SMA kelas XII gratis untuk angkt 2026\nyg mau silahkan ya wst",
          timestamp: "7j",
          imageUrl: "images/postingan2.jpg",
          profileImage: 'images/profil4.jpg',
          showBotLabel: true,
          commentsCount: 584,
          retweetsCount: 996,
          likesCount: 5000,
          viewsText: '100rb',
        ),
      ],
    );
  }
}

class PostCard extends StatelessWidget {
  final String username;
  final String handle;
  final String content;
  final String timestamp;
  final String? imageUrl;
  final String profileImage;
  final bool isVerified;
  final bool showGreenLove;
  final bool showBotLabel;
  final String? extraNote;
  final int commentsCount;
  final int retweetsCount;
  final int likesCount;
  final String? viewsText;

  const PostCard({
    super.key,
    required this.username,
    required this.handle,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    required this.profileImage,
    this.isVerified = false,
    this.showGreenLove = false,
    this.showBotLabel = false,
    this.extraNote,
    required this.commentsCount,
    required this.retweetsCount,
    required this.likesCount,
    this.viewsText,
  });

  @override
  Widget build(BuildContext context) {
    // Cek apakah layar kecil (mobile)
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return GestureDetector(
      onTap: () {
        // Buka tampilan detail saat postingan diketuk
        openPostDetail(
          context,
          username: username,
          handle: handle,
          content: content,
          timestamp: timestamp,
          imageUrl: imageUrl,
          profileImage: profileImage,
          isVerified: isVerified,
          commentsCount: commentsCount,
          retweetsCount: retweetsCount,
          likesCount: likesCount,
          viewsText: viewsText ?? '',
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[800]!,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(profileImage),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info row
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified)
                              Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 15,
                                ),
                              ),
                            Text(
                              " · $timestamp",
                             style: TextStyle(color: Colors.grey, fontSize: 14),
                           ),
                           Spacer(),
                           Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                         ],
                       ),
                       
                       // Handle text
                       Text(
                         handle,
                         style: TextStyle(color: Colors.grey, fontSize: 14),
                       ),
                       
                       // Bot label if needed
                       if (showBotLabel)
                         Padding(
                           padding: const EdgeInsets.only(top: 4),
                           child: Row(
                             children: [
                               Icon(Icons.android, size: 14, color: Colors.grey),
                               SizedBox(width: 4),
                               Text(
                                 "Otomatis",
                                 style: TextStyle(
                                   color: Colors.grey,
                                   fontSize: 12,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       
                       const SizedBox(height: 8),
                       
                       // Content
                       Text(
                         content,
                         style: TextStyle(fontSize: 15),
                       ),
                       
                       // Image if any
                       if (imageUrl != null) ...[
                         const SizedBox(height: 8),
                         ClipRRect(
                           borderRadius: BorderRadius.circular(12),
                           child: Image.asset(imageUrl!),
                         ),
                       ],
                       
                       const SizedBox(height: 12),
                       
                       // Interaction icons - match with image
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           _buildInteractionIcon(
                             Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
                             commentsCount,
                           ),
                           _buildInteractionIcon(
                             Icon(Icons.repeat, color: Colors.grey, size: 18),
                             retweetsCount,
                           ),
                           _buildInteractionIcon(
                             Icon(Icons.favorite_border, color: Colors.grey, size: 18),
                             likesCount,
                           ),
                           Row(
                             children: [
                               Icon(Icons.bar_chart, color: Colors.grey, size: 18),
                               SizedBox(width: 4),
                               Text(
                                 viewsText ?? '',
                                 style: TextStyle(color: Colors.grey, fontSize: 13),
                               ),
                             ],
                           ),
                           Icon(Icons.share_outlined, color: Colors.grey, size: 18),
                         ],
                       ),
                     ],
                   ),
                 ),
               ],
             ),
           ),
         ],
       ),
     ),
   );
 }

 Widget _buildInteractionIcon(Widget icon, int count) {
   return Row(
     children: [
       icon,
       SizedBox(width: 4),
       Text(
         formatCount(count),
         style: TextStyle(color: Colors.grey, fontSize: 13),
       ),
     ],
   );
 }
}

// Fungsi untuk membuka detail postingan
void openPostDetail(BuildContext context, {
 required String username,
 required String handle,
 required String content,
 required String timestamp,
 String? imageUrl,
 required String profileImage,
 required bool isVerified,
 required int commentsCount,
 required int retweetsCount,
 required int likesCount,
 required String viewsText,
}) {
 final bool isMobile = MediaQuery.of(context).size.width < 600;
 
 if (isMobile) {
   // Tampilan fullscreen untuk mobile
   Navigator.of(context).push(
     MaterialPageRoute(
       builder: (context) => PostDetailMobileScreen(
         username: username,
         handle: handle,
         content: content,
         timestamp: timestamp,
         imageUrl: imageUrl,
         profileImage: profileImage,
         isVerified: isVerified,
         commentsCount: commentsCount,
         retweetsCount: retweetsCount,
         likesCount: likesCount,
         viewsText: viewsText,
       ),
     ),
   );
 } else {
   // Tampilan dialog untuk desktop
   showDialog(
     context: context,
     builder: (context) => Dialog(
       backgroundColor: Colors.transparent,
       insetPadding: EdgeInsets.symmetric(horizontal: 100),
       child: PostDetailDesktopScreen(
         username: username,
         handle: handle,
         content: content,
         timestamp: timestamp,
         imageUrl: imageUrl,
         profileImage: profileImage,
         isVerified: isVerified,
         commentsCount: commentsCount,
         retweetsCount: retweetsCount,
         likesCount: likesCount,
         viewsText: viewsText,
       ),
     ),
   );
 }
}

// Tampilan detail postingan untuk Mobile - fullscreen
class PostDetailMobileScreen extends StatelessWidget {
 final String username;
 final String handle;
 final String content;
 final String timestamp;
 final String? imageUrl;
 final String profileImage;
 final bool isVerified;
 final int commentsCount;
 final int retweetsCount;
 final int likesCount;
 final String viewsText;

 const PostDetailMobileScreen({
   Key? key,
   required this.username,
   required this.handle,
   required this.content,
   required this.timestamp,
   this.imageUrl,
   required this.profileImage,
   required this.isVerified,
   required this.commentsCount,
   required this.retweetsCount,
   required this.likesCount,
   required this.viewsText,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.black,
       elevation: 0,
       leading: IconButton(
         icon: Icon(Icons.close, color: Colors.white),
         onPressed: () => Navigator.of(context).pop(),
       ),
       actions: [
         IconButton(
           icon: Icon(Icons.more_horiz, color: Colors.white),
           onPressed: () {},
         ),
       ],
     ),
     body: SingleChildScrollView(
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Gambar postingan sebagai full-width content
           if (imageUrl != null)
             Container(
               width: double.infinity,
               child: Image.asset(
                 imageUrl!,
                 fit: BoxFit.cover,
               ),
             ),
           
           // Info interaksi
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 _buildInteractionIcon(
                   Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                   commentsCount,
                   color: Colors.white,
                 ),
                 _buildInteractionIcon(
                   Icon(Icons.repeat, color: Colors.white, size: 20),
                   retweetsCount,
                   color: Colors.white,
                 ),
                 _buildInteractionIcon(
                   Icon(Icons.favorite_border, color: Colors.white, size: 20),
                   likesCount,
                   color: Colors.white,
                 ),
                 Row(
                   children: [
                     Icon(Icons.bar_chart, color: Colors.white, size: 20),
                     SizedBox(width: 4),
                     Text(
                       viewsText,
                       style: TextStyle(color: Colors.white),
                     ),
                   ],
                 ),
                 Icon(Icons.share_outlined, color: Colors.white, size: 20),
               ],
             ),
           ),
         ],
       ),
     ),
   );
 }
 
 Widget _buildInteractionIcon(Widget icon, int count, {Color color = Colors.grey}) {
   return Row(
     children: [
       icon,
       SizedBox(width: 4),
       Text(
         formatCount(count),
         style: TextStyle(color: color),
       ),
     ],
   );
 }
}

// Tampilan detail postingan untuk Desktop - dialog
class PostDetailDesktopScreen extends StatelessWidget {
 final String username;
 final String handle;
 final String content;
 final String timestamp;
 final String? imageUrl;
 final String profileImage;
 final bool isVerified;
 final int commentsCount;
 final int retweetsCount;
 final int likesCount;
 final String viewsText;

 const PostDetailDesktopScreen({
   Key? key,
   required this.username,
   required this.handle,
   required this.content,
   required this.timestamp,
   this.imageUrl,
   required this.profileImage,
   required this.isVerified,
   required this.commentsCount,
   required this.retweetsCount,
   required this.likesCount,
   required this.viewsText,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Container(
     constraints: BoxConstraints(
       maxWidth: MediaQuery.of(context).size.width * 0.8,
       maxHeight: MediaQuery.of(context).size.height * 0.8,
     ),
     decoration: BoxDecoration(
       color: Colors.black,
       borderRadius: BorderRadius.circular(16),
     ),
     child: ClipRRect(
       borderRadius: BorderRadius.circular(16),
       child: Row(
         children: [
           // Bagian kiri - gambar postingan (tidak terpotong)
           if (imageUrl != null)
             Expanded(
               flex: 1,
               child: Image.asset(
                 imageUrl!,
                 fit: BoxFit.contain,
               ),
             ),
           
           // Bagian kanan - detail postingan & komentar
           Expanded(
             flex: 1,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 // Header dengan tombol close
                 Container(
                   padding: const EdgeInsets.all(12),
                   alignment: Alignment.centerRight,
                   child: IconButton(
                     icon: Icon(Icons.close, color: Colors.white),
                     onPressed: () => Navigator.of(context).pop(),
                   ),
                 ),
                 
                 // Detail postingan
                 Expanded(
                   child: SingleChildScrollView(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         // Informasi pengguna
                         Padding(
                           padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                           child: Row(
                             children: [
                               CircleAvatar(
                                 backgroundImage: AssetImage(profileImage),
                                 radius: 20,
                               ),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Row(
                                       children: [
                                         Text(
                                           username,
                                           style: const TextStyle(
                                             fontWeight: FontWeight.bold,
                                             fontSize: 16,
                                           ),
                                           overflow: TextOverflow.ellipsis,
                                         ),
                                         if (isVerified)
                                           Padding(
                                             padding: EdgeInsets.only(left: 4),
                                             child: Icon(
                                               Icons.verified,
                                               color: Colors.blue,
                                               size: 16,
                                             ),
                                           ),
                                       ],
                                     ),
                                     Text(
                                       handle,
                                       style: TextStyle(color: Colors.grey, fontSize: 14),
                                     ),
                                   ],
                                 ),
                               ),
                               Icon(Icons.more_horiz, color: Colors.grey),
                             ],
                           ),
                         ),
                         
                         // Konten postingan
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16),
                           child: Text(
                             content,
                             style: TextStyle(fontSize: 16),
                           ),
                         ),
                         
                         // Timestamp & stats
                         Padding(
                           padding: const EdgeInsets.all(16),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 timestamp,
                                 style: TextStyle(color: Colors.grey),
                               ),
                               Divider(color: Colors.grey[800]),
                               // Stats row
                               Row(
                                 children: [
                                   _buildStat(commentsCount.toString(), 'Komentar'),
                                   SizedBox(width: 16),
                                   _buildStat(retweetsCount.toString(), 'Retweet'),
                                   SizedBox(width: 16),
                                   _buildStat(likesCount.toString(), 'Suka'),
                                 ],
                               ),
                               Divider(color: Colors.grey[800]),
                             ],
                           ),
                         ),
                         
                         // Interaction buttons
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceAround,
                             children: [
                               IconButton(
                                 icon: Icon(Icons.chat_bubble_outline, color: Colors.grey),
                                 onPressed: () {},
                               ),
                               IconButton(
                                 icon: Icon(Icons.repeat, color: Colors.grey),
                                 onPressed: () {},
                               ),
                               IconButton(
                                 icon: Icon(Icons.favorite_border, color: Colors.grey),
                                 onPressed: () {},
                               ),
                               IconButton(
                                 icon: Icon(Icons.bar_chart, color: Colors.grey),
                                 onPressed: () {},
                               ),
                               IconButton(
                                 icon: Icon(Icons.share_outlined, color: Colors.grey),
                                 onPressed: () {},
                               ),
                             ],
                           ),
                         ),
                         
                         Divider(color: Colors.grey[800]),
                         
                         // Dummy comments
                         _buildCommentItem(
                           username: "User 1",
                           handle: "@user1",
                           timestamp: "1j",
                           content: "Great post! Love it.",
                           profileImage: "images/avatar1.jpg",
                         ),
                         _buildCommentItem(
                           username: "User 2",
                           handle: "@user2",
                           timestamp: "2j",
                           content: "Couldn't agree more with this.",
                           profileImage: "images/avatar2.jpg",
                         ),
                         _buildCommentItem(
                           username: "User 3",
                           handle: "@user3",
                           timestamp: "3j",
                           content: "Thanks for sharing this!",
                           profileImage: "images/avatar3.jpg",
                         ),
                       ],
                     ),
                   ),
                 ),
               ],
             ),
           ),
         ],
       ),
     ),
   );
 }
 
 Widget _buildStat(String count, String label) {
   return Row(
     children: [
       Text(
         count,
         style: TextStyle(fontWeight: FontWeight.bold),
       ),
       SizedBox(width: 4),
       Text(
         label,
         style: TextStyle(color: Colors.grey),
       ),
     ],
   );
 }
 
 Widget _buildCommentItem({
   required String username,
   required String handle,
   required String timestamp,
   required String content,
   required String profileImage,
 }) {
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
           backgroundImage: AssetImage(profileImage),
           radius: 16,
         ),
         SizedBox(width: 12),
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   Text(
                     username,
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 14,
                     ),
                   ),
                   SizedBox(width: 4),
                   Text(
                     "$handle · $timestamp",
                     style: TextStyle(color: Colors.grey, fontSize: 12),
                   ),
                 ],
               ),
               SizedBox(height: 4),
               Text(content),
               SizedBox(height: 8),
               // Comment interaction buttons
               Row(
                 children: [
                   Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 16),
                   SizedBox(width: 16),
                   Icon(Icons.repeat, color: Colors.grey, size: 16),
                   SizedBox(width: 16),
                   Icon(Icons.favorite_border, color: Colors.grey, size: 16),
                   SizedBox(width: 16),
                   Icon(Icons.share_outlined, color: Colors.grey, size: 16),
                 ],
               ),
             ],
           ),
         ),
       ],
     ),
   );
 }
}

// Fungsi format angka ke 'rb' untuk ribu
String formatCount(int count) {
 if (count >= 1000) {
   double inThousands = count / 1000;
   if (inThousands == inThousands.toInt()) {
     return '${inThousands.toInt()}rb';
   } else {
     return '${inThousands.toStringAsFixed(1)}rb';
   }
 }
 return count.toString();
}

// Widget Premium Box yang ditampilkan di sidebar kanan
class PremiumBox extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return Container(
     padding: const EdgeInsets.all(16),
     decoration: BoxDecoration(
       color: Colors.grey[900],
       borderRadius: BorderRadius.circular(16),
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text(
           'Berlangganan Premium',
           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
         ),
         const SizedBox(height: 8),
         const Text(
           'Berlangganan untuk mengakses fitur-fitur baru dan, jika memenuhi syarat, menerima bagi hasil pendapatan.',
           style: TextStyle(color: Colors.grey, fontSize: 14),
         ),
         const SizedBox(height: 12),
         ElevatedButton(
           onPressed: () {},
           style: ElevatedButton.styleFrom(
             backgroundColor: Colors.blue,
             foregroundColor: Colors.white,
             padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(20),
             ),
           ),
           child: const Text(
             "Berlangganan",
             style: TextStyle(
               fontWeight: FontWeight.bold,
               fontSize: 14,
             ),
           ),
         ),
       ],
     ),
   );
 }
}

// Widget Trending yang ditampilkan di sidebar kanan
class TrendingWidget extends StatelessWidget {
 final List<Map<String, String>> trends = [
   {
     'topic': 'Sedang tren dalam topik Indonesia',
     'title': 'Bali',
     'posts': '17,8 rb postingan',
   },
   {
     'topic': 'Sedang tren dalam topik Indonesia',
     'title': 'Putri KW',
     'posts': '1.079 postingan',
   },
   {
     'topic': 'Sedang tren dalam topik Indonesia',
     'title': 'Biru',
     'posts': '8.210 postingan',
   },
 ];

 @override
 Widget build(BuildContext context) {
   return Container(
     padding: const EdgeInsets.all(16),
     decoration: BoxDecoration(
       color: Colors.grey[900],
       borderRadius: BorderRadius.circular(16),
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text(
           'Sedang hangat dibicarakan',
           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
         ),
         const SizedBox(height: 12),

         ...trends.asMap().entries.map((entry) {
           final index = entry.key;
           final trend = entry.value;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (index > 0) Divider(color: Colors.grey[800]),
               Padding(
                 padding: const EdgeInsets.symmetric(vertical: 8),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           trend['topic']!,
                           style: const TextStyle(
                             color: Colors.grey,
                             fontSize: 12,
                           ),
                         ),
                         Icon(Icons.more_horiz, color: Colors.grey, size: 16),
                       ],
                     ),
                     const SizedBox(height: 2),
                     Text(
                       trend['title']!,
                       style: const TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 15,
                       ),
                     ),
                     Text(
                       trend['posts']!,
                       style: const TextStyle(
                         color: Colors.grey,
                         fontSize: 12,
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           );
         }).toList(),
         const SizedBox(height: 8),
         Text(
           'Tampilkan lebih banyak',
           style: TextStyle(color: Colors.blue, fontSize: 14),
         ),
       ],
     ),
   );
 }
}

// Widget Follow Suggestions yang ditampilkan di sidebar kanan
class FollowSuggestions extends StatelessWidget {
 final List<Map<String, String>> suggestions = [
   {
     'name': 'red is ch30l 🍒',
     'handle': '@redxch30l',
     'image': 'images/rekom1.jpg',
   },
   {
     'name': 'gailord',
     'handle': '@hoonsblicky',
     'image': 'images/rekom2.jpg',
   },
   {
     'name': 'el | ia but MOLO ENTHUSIAST',
     'handle': '@woozicrunch',
     'image': 'images/rekom3.jpg',
   },
 ];

 @override
 Widget build(BuildContext context) {
   return Container(
     padding: const EdgeInsets.all(16),
     decoration: BoxDecoration(
       color: Colors.grey[900],
       borderRadius: BorderRadius.circular(16),
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text(
           'Untuk Diikuti',
           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
         ),
         const SizedBox(height: 8),
         ...suggestions.asMap().entries.map((entry) {
           final index = entry.key;
           final user = entry.value;
           return Column(
             children: [
               if (index > 0) Divider(color: Colors.grey[800]),
               Padding(
                 padding: const EdgeInsets.symmetric(vertical: 8.0),
                 child: Row(
                   children: [
                     CircleAvatar(
                       backgroundImage: AssetImage(user['image']!),
                       radius: 20,
                     ),
                     const SizedBox(width: 10),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             user['name']!,
                             style: const TextStyle(
                               fontWeight: FontWeight.bold,
                               fontSize: 14,
                             ),
                             overflow: TextOverflow.ellipsis,
                           ),
                           Text(
                             user['handle']!,
                             style: const TextStyle(color: Colors.grey, fontSize: 13),
                           ),
                         ],
                       ),
                     ),
                     Container(
                       padding: const EdgeInsets.symmetric(
                         horizontal: 16,
                         vertical: 8,
                       ),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(20),
                       ),
                       child: const Text(
                         'Ikuti',
                         style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           );
         }).toList(),
         const SizedBox(height: 8),
         Text(
           'Tampilkan lebih banyak',
           style: TextStyle(color: Colors.blue, fontSize: 14),
         ),
       ],
     ),
   );
 }
}

// Placeholder Screens
class ExploreScreen extends StatelessWidget {
 const ExploreScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.black,
       elevation: 0,
       title: Text('Jelajahi'),
       leading: IconButton(
         icon: Icon(Icons.arrow_back),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: Center(
       child: Text(
         'Halaman Jelajahi',
         style: TextStyle(color: Colors.white, fontSize: 24),
       ),
     ),
   );
 }
}

class TrendsScreen extends StatelessWidget {
 const TrendsScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.black,
       elevation: 0,
       title: Text('Trending'),
       leading: IconButton(
         icon: Icon(Icons.arrow_back),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: Center(
       child: Text(
         'Halaman Trending',
         style: TextStyle(color: Colors.white, fontSize: 24),
       ),
     ),
   );
 }
}

class NotificationsScreen extends StatelessWidget {
 const NotificationsScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.black,
       elevation: 0,
       title: Text('Notifikasi'),
       leading: IconButton(
         icon: Icon(Icons.arrow_back),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: Center(
       child: Text(
         'Halaman Notifikasi',
         style: TextStyle(color: Colors.white, fontSize: 24),
       ),
     ),
   );
 }
}

class MessagesScreen extends StatelessWidget {
 const MessagesScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.black,
       elevation: 0,
       title: Text('Pesan'),
       leading: IconButton(
         icon: Icon(Icons.arrow_back),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: Center(
       child: Text(
         'Halaman Pesan',
         style: TextStyle(color: Colors.white, fontSize: 24),
       ),
     ),
   );
 }
}

class BookmarksScreen extends StatelessWidget {
 const BookmarksScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.black,
       elevation: 0,
       title: Text('Bookmark'),
       leading: IconButton(
         icon: Icon(Icons.arrow_back),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: Center(
       child: Text(
         'Halaman Bookmark',
         style: TextStyle(color: Colors.white, fontSize: 24),
       ),
     ),
   );
 }
}

class PremiumScreen extends StatelessWidget {
 const PremiumScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.black,
       elevation: 0,
       title: Text('X Premium'),
       leading: IconButton(
         icon: Icon(Icons.arrow_back),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text(
             'X Premium',
             style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
           ),
           SizedBox(height: 20),
           Text(
             'Dapatkan fitur-fitur premium dan keuntungan lainnya',
             style: TextStyle(color: Colors.grey, fontSize: 16),
           ),
           SizedBox(height: 30),
           ElevatedButton(
             onPressed: () {},
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.blue,
               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(30),
               ),
             ),
             child: Text('Berlangganan Sekarang'),
           ),
         ],
       ),
     ),
   );
 }
}

class SettingsScreen extends StatelessWidget {
 const SettingsScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.black,
       elevation: 0,
       title: Text('Pengaturan dan Privasi'),
       leading: IconButton(
         icon: Icon(Icons.arrow_back),
         onPressed: () => Navigator.of(context).pop(),
         ),
     ),
     body: Center(
       child: Text(
         'Halaman Pengaturan',
         style: TextStyle(color: Colors.white, fontSize: 24),
       ),
     ),
   );
 }
}

class HelpScreen extends StatelessWidget {
 const HelpScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     appBar: AppBar(
       backgroundColor: Colors.black,
       elevation: 0,
       title: Text('Bantuan'),
       leading: IconButton(
         icon: Icon(Icons.arrow_back),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: Center(
       child: Text(
         'Halaman Bantuan',
         style: TextStyle(color: Colors.white, fontSize: 24),
       ),
     ),
   );
 }
}