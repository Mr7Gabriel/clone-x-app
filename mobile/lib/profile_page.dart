import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'notification_page.dart';
import 'message_page.dart';
import 'bookmark_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final String profileBanner = 'images/profile_banner.jpg';
  final String profileImage = 'images/me.jpg';
  final String name = 'Mis X';
  final String username = '@xoxo900';
  final String bio = 'Flutter Developer | UI/UX Enthusiast | Learning and growing every day';
  final String location = 'Makassar, Indonesia';
  final String website = 'flutter.dev';
  final String joinDate = 'Joined April 2023';
  final int following = 245;
  final int followers = 120;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.black,
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(mobile: true),
              ),
              title: innerBoxIsScrolled ? Text(name) : null,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => HomeScreen())
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            _buildProfileInfo(mobile: true),
            _buildProfileStats(mobile: true),
            _buildTabBar(),
            Expanded(
              child: _buildTabBarView(),
            ),
          ],
        ),
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
          
          // Main content
          Expanded(
            flex: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: Colors.black,
                    expandedHeight: 250,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildProfileHeader(),
                    ),
                    title: innerBoxIsScrolled ? Text(name) : null,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ];
              },
              body: Column(
                children: [
                  _buildProfileInfo(),
                  SizedBox(height: 16),
                  _buildProfileStats(),
                  _buildTabBar(),
                  Expanded(
                    child: _buildTabBarView(),
                  ),
                ],
              ),
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

  Widget _buildProfileHeader({bool mobile = false}) {
    return Stack(
      children: [
        // Profile banner
        Container(
          height: mobile ? 130 : 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(profileBanner),
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Profile image
        Positioned(
          left: 20,
          top: mobile ? 80 : 140,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: CircleAvatar(
              radius: mobile ? 40 : 50,
              backgroundImage: AssetImage(profileImage),
            ),
          ),
        ),
        
        // Edit profile button
        Positioned(
          right: 20,
          top: mobile ? 140 : 210,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Edit Profile'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo({bool mobile = false}) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: mobile ? 40 : 0),
          Text(
            name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            username,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          Text(bio),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey, size: 16),
              SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(width: 16),
              Icon(Icons.link, color: Colors.grey, size: 16),
              SizedBox(width: 4),
              Text(
                website,
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey, size: 16),
              SizedBox(width: 4),
              Text(
                joinDate,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats({bool mobile = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: following.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: ' Mengikuti',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: followers.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: ' Pengikut',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.blue,
        tabs: [
          Tab(text: 'Postingan'),
          Tab(text: 'Balasan'),
          Tab(text: 'Media'),
          Tab(text: 'Suka'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPostsList(),
        _buildRepliesList(),
        _buildMediaList(),
        _buildLikesList(),
      ],
    );
  }

  Widget _buildPostsList() {
    // Sample posts
    List<Map<String, dynamic>> posts = [
      {
        'content': 'Excited to start learning Flutter! 🚀 #FlutterDev',
        'timestamp': '2d',
        'likes': 45,
        'retweets': 12,
        'replies': 5,
      },
      {
        'content': 'Just published my first Flutter app on Play Store. Check it out! #Flutter #MobileApp',
        'timestamp': '5d',
        'likes': 87,
        'retweets': 23,
        'replies': 14,
        'imageUrl': 'images/flutter_app.jpg',
      },
      {
        'content': 'Working with Flutter is so much fun! The hot reload feature is a game changer for development.',
        'timestamp': '1w',
        'likes': 120,
        'retweets': 32,
        'replies': 18,
      },
    ];

    return posts.isEmpty
        ? _buildEmptyState('Kamu belum memposting apa pun.')
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostItem(post);
            },
          );
  }

  Widget _buildRepliesList() {
   return _buildEmptyState('Belum ada balasan.');
 }

 Widget _buildMediaList() {
   return _buildEmptyState('Belum ada media.');
 }

 Widget _buildLikesList() {
   return _buildEmptyState('Belum ada suka.');
 }

 Widget _buildEmptyState(String message) {
   return Center(
     child: Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey),
         SizedBox(height: 20),
         Text(
           message,
           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
         ),
         SizedBox(height: 10),
         Text(
           'Ketika Anda memposting, konten akan muncul di sini.',
           style: TextStyle(color: Colors.grey),
           textAlign: TextAlign.center,
         ),
       ],
     ),
   );
 }

 Widget _buildPostItem(Map<String, dynamic> post) {
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
               backgroundImage: AssetImage(profileImage),
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
                         name,
                         style: TextStyle(fontWeight: FontWeight.bold),
                       ),
                       SizedBox(width: 4),
                       Text(
                         username,
                         style: TextStyle(color: Colors.grey),
                       ),
                       Text(
                         ' · ${post['timestamp']}',
                         style: TextStyle(color: Colors.grey),
                       ),
                     ],
                   ),
                   SizedBox(height: 4),
                   Text(post['content']),
                   if (post.containsKey('imageUrl')) ...[
                     SizedBox(height: 10),
                     ClipRRect(
                       borderRadius: BorderRadius.circular(12),
                       child: Image.asset(
                         post['imageUrl'],
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
                         count: post['replies'],
                       ),
                       _buildInteractionIcon(
                         icon: Icons.repeat,
                         count: post['retweets'],
                       ),
                       _buildInteractionIcon(
                         icon: Icons.favorite_border,
                         count: post['likes'],
                       ),
                       Row(
                         children: [
                           IconButton(
                             icon: Icon(Icons.bookmark_border, color: Colors.grey, size: 16),
                             onPressed: () {},
                             constraints: BoxConstraints(),
                             padding: EdgeInsets.symmetric(horizontal: 8),
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
           isActive: true,
           onTap: () {
             // Already on Profile page
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
             // Show profile menu (already on profile page)
           },
           child: Container(
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               border: Border.all(color: Colors.blue, width: 2),
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
               'Kamu mungkin menyukai',
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
       
       // Trending topics
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
               'Tren untuk Anda',
               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
             ),
             SizedBox(height: 16),
             _buildTrendingTopic(
               'Flutter',
               '23.5K posts'
             ),
             Divider(color: Colors.grey[800], height: 16),
             _buildTrendingTopic(
               'Dart',
               '12.7K posts'
             ),
             Divider(color: Colors.grey[800], height: 16),
             _buildTrendingTopic(
               'MobileApp',
               '45.2K posts'
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

 Widget _buildTrendingTopic(String topic, String posts) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text(
         'Trending',
         style: TextStyle(color: Colors.grey, fontSize: 12),
       ),
       SizedBox(height: 4),
       Text(
         topic,
         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
       ),
       SizedBox(height: 4),
       Text(
         posts,
         style: TextStyle(color: Colors.grey, fontSize: 12),
       ),
     ],
   );
 }
}