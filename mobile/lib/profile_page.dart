import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home_page.dart';
import 'explore_page.dart';
import 'notification_page.dart';
import 'message_page.dart';
import 'bookmark_page.dart';
import 'user_provider.dart';
import 'models.dart';
import 'api_service.dart';

class ProfilePage extends StatefulWidget {
  final int? userId; // If null, show current user profile
  
  const ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  User? _profileUser;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isOwnProfile = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (widget.userId == null || widget.userId == currentUser?.id) {
        // Show current user profile
        _profileUser = currentUser;
        _isOwnProfile = true;
      } else {
        // Load other user profile
        _profileUser = await _apiService.getUserById(widget.userId!);
        _isOwnProfile = false;
        
        if (_profileUser != null && currentUser != null) {
          _isFollowing = await _apiService.isFollowing(_profileUser!.id);
        }
      }

      if (_profileUser != null) {
        _userPosts = await _apiService.getUserPosts(_profileUser!.id);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _followUser() async {
    if (_profileUser == null) return;

    try {
      final following = await _apiService.followUser(_profileUser!.id);
      setState(() {
        _isFollowing = following;
        if (following) {
          _profileUser = User(
            id: _profileUser!.id,
            username: _profileUser!.username,
            email: _profileUser!.email,
            name: _profileUser!.name,
            bio: _profileUser!.bio,
            location: _profileUser!.location,
            website: _profileUser!.website,
            profileImage: _profileUser!.profileImage,
            bannerImage: _profileUser!.bannerImage,
            isVerified: _profileUser!.isVerified,
            followerCount: _profileUser!.followerCount + 1,
            followingCount: _profileUser!.followingCount,
            createdAt: _profileUser!.createdAt,
            updatedAt: _profileUser!.updatedAt,
          );
        } else {
          _profileUser = User(
            id: _profileUser!.id,
            username: _profileUser!.username,
            email: _profileUser!.email,
            name: _profileUser!.name,
            bio: _profileUser!.bio,
            location: _profileUser!.location,
            website: _profileUser!.website,
            profileImage: _profileUser!.profileImage,
            bannerImage: _profileUser!.bannerImage,
            isVerified: _profileUser!.isVerified,
            followerCount: _profileUser!.followerCount - 1,
            followingCount: _profileUser!.followingCount,
            createdAt: _profileUser!.createdAt,
            updatedAt: _profileUser!.updatedAt,
          );
        }
      });
    } catch (e) {
      print('Error following user: $e');
    }
  }

  Future<void> _updateProfileImages(bool isProfileImage) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      try {
        String? imageUrl;
        if (isProfileImage) {
          imageUrl = await _apiService.uploadProfileImage(File(image.path));
        } else {
          imageUrl = await _apiService.uploadBannerImage(File(image.path));
        }

        if (imageUrl != null) {
          setState(() {
            if (isProfileImage) {
              _profileUser = User(
                id: _profileUser!.id,
                username: _profileUser!.username,
                email: _profileUser!.email,
                name: _profileUser!.name,
                bio: _profileUser!.bio,
                location: _profileUser!.location,
                website: _profileUser!.website,
                profileImage: imageUrl,
                bannerImage: _profileUser!.bannerImage,
                isVerified: _profileUser!.isVerified,
                followerCount: _profileUser!.followerCount,
                followingCount: _profileUser!.followingCount,
                createdAt: _profileUser!.createdAt,
                updatedAt: _profileUser!.updatedAt,
              );
            } else {
              _profileUser = User(
                id: _profileUser!.id,
                username: _profileUser!.username,
                email: _profileUser!.email,
                name: _profileUser!.name,
                bio: _profileUser!.bio,
                location: _profileUser!.location,
                website: _profileUser!.website,
                profileImage: _profileUser!.profileImage,
                bannerImage: imageUrl,
                isVerified: _profileUser!.isVerified,
                followerCount: _profileUser!.followerCount,
                followingCount: _profileUser!.followingCount,
                createdAt: _profileUser!.createdAt,
                updatedAt: _profileUser!.updatedAt,
              );
            }
          });

          // Update UserProvider if it's own profile
          if (_isOwnProfile) {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            userProvider.updateCurrentUser(_profileUser!);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isProfileImage ? 'Profile image updated!' : 'Banner image updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error updating image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    if (_profileUser == null) return;

    final nameController = TextEditingController(text: _profileUser!.name);
    final bioController = TextEditingController(text: _profileUser!.bio ?? '');
    final locationController = TextEditingController(text: _profileUser!.location ?? '');
    final websiteController = TextEditingController(text: _profileUser!.website ?? '');

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
                    Expanded(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          final updatedUser = await _apiService.updateUserProfile(
                            _profileUser!.id,
                            name: nameController.text,
                            bio: bioController.text,
                            location: locationController.text,
                            website: websiteController.text,
                          );

                          if (updatedUser != null) {
                            setState(() {
                              _profileUser = updatedUser;
                            });

                            // Update UserProvider if it's own profile
                            if (_isOwnProfile) {
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              userProvider.updateCurrentUser(updatedUser);
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          print('Error updating profile: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update profile'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Save', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: websiteController,
                  decoration: InputDecoration(
                    labelText: 'Website',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    if (_profileUser == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'User not found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

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
              title: innerBoxIsScrolled ? Text(_profileUser!.name) : null,
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
                    title: innerBoxIsScrolled ? Text(_profileUser!.name) : null,
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
        GestureDetector(
          onTap: _isOwnProfile ? () => _updateProfileImages(false) : null,
          child: Container(
            height: mobile ? 130 : 200,
            decoration: BoxDecoration(
              image: _profileUser!.bannerImage != null
                  ? DecorationImage(
                      image: NetworkImage('http://localhost:3000/${_profileUser!.bannerImage}'),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: _profileUser!.bannerImage == null ? Colors.grey[800] : null,
            ),
            child: _profileUser!.bannerImage == null && _isOwnProfile
                ? Center(
                    child: Icon(Icons.camera_alt, color: Colors.grey[600], size: 30),
                  )
                : null,
          ),
        ),
        
        // Profile image
        Positioned(
          left: 20,
          top: mobile ? 80 : 140,
          child: GestureDetector(
            onTap: _isOwnProfile ? () => _updateProfileImages(true) : null,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: CircleAvatar(
                radius: mobile ? 40 : 50,
                backgroundImage: _profileUser!.profileImage != null
                    ? NetworkImage('http://localhost:3000/${_profileUser!.profileImage}')
                    : AssetImage('images/default_avatar.jpg') as ImageProvider,
              ),
            ),
          ),
        ),
        
        // Action button
        Positioned(
          right: 20,
          top: mobile ? 140 : 210,
          child: _isOwnProfile
              ? OutlinedButton(
                  onPressed: _showEditProfileDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Edit Profile'),
                )
              : ElevatedButton(
                  onPressed: _followUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing ? Colors.grey[800] : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(_isFollowing ? 'Following' : 'Follow'),
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
          Row(
            children: [
              Text(
                _profileUser!.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (_profileUser!.isVerified)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.verified, color: Colors.blue, size: 20),
                ),
            ],
          ),
          Text(
            '@${_profileUser!.username}',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          if (_profileUser!.bio != null && _profileUser!.bio!.isNotEmpty)
            Text(_profileUser!.bio!),
          SizedBox(height: 12),
          Row(
            children: [
              if (_profileUser!.location != null && _profileUser!.location!.isNotEmpty) ...[
                Icon(Icons.location_on, color: Colors.grey, size: 16),
                SizedBox(width: 4),
                Text(
                  _profileUser!.location!,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 16),
              ],
              if (_profileUser!.website != null && _profileUser!.website!.isNotEmpty) ...[
                Icon(Icons.link, color: Colors.grey, size: 16),
                SizedBox(width: 4),
                Text(
                  _profileUser!.website!,
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey, size: 16),
              SizedBox(width: 4),
              Text(
                'Joined ${_formatJoinDate(_profileUser!.createdAt)}',
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
          GestureDetector(
            onTap: () => _showFollowingDialog(),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _formatCount(_profileUser!.followingCount),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextSpan(
                    text: ' Mengikuti',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20),
          GestureDetector(
            onTap: () => _showFollowersDialog(),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _formatCount(_profileUser!.followerCount),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextSpan(
                    text: ' Pengikut',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
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
    if (_userPosts.isEmpty) {
      return _buildEmptyState('Belum ada postingan.');
    }

    return ListView.builder(
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return _buildPostItem(post);
      },
    );
  }

  Widget _buildRepliesList() {
    return _buildEmptyState('Belum ada balasan.');
  }

  Widget _buildMediaList() {
    final mediaPosts = _userPosts.where((post) => post.imageUrl != null).toList();
    
    if (mediaPosts.isEmpty) {
      return _buildEmptyState('Belum ada media.');
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: mediaPosts.length,
      itemBuilder: (context, index) {
        final post = mediaPosts[index];
        return GestureDetector(
          onTap: () => _showPostDetail(post),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'http://localhost:3000/${post.imageUrl}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
        );
      },
    );
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
            _isOwnProfile 
              ? 'Ketika Anda memposting, konten akan muncul di sini.'
              : 'Pengguna ini belum memposting apa pun.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post) {
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
                backgroundImage: _profileUser!.profileImage != null
                    ? NetworkImage('http://localhost:3000/${_profileUser!.profileImage}')
                    : AssetImage('images/default_avatar.jpg') as ImageProvider,
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
                          _profileUser!.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (_profileUser!.isVerified)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.verified, color: Colors.blue, size: 16),
                          ),
                        SizedBox(width: 4),
                        Text(
                          '@${_profileUser!.username}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          ' · ${_formatTime(post.createdAt)}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(post.content),
                    if (post.imageUrl != null) ...[
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'http://localhost:3000/${post.imageUrl}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            );
                          },
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
                          count: post.replyCount,
                          onTap: () => _showReplyDialog(post),
                        ),
                        _buildInteractionIcon(
                          icon: Icons.repeat,
                          count: post.retweetCount,
                          onTap: () => _retweetPost(post),
                        ),
                        _buildInteractionIcon(
                          icon: Icons.favorite_border,
                          count: post.likeCount,
                          onTap: () => _likePost(post),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.bookmark_border, color: Colors.grey, size: 16),
                              onPressed: () => _bookmarkPost(post),
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            IconButton(
                              icon: Icon(Icons.share_outlined, color: Colors.grey, size: 16),
                              onPressed: () => _sharePost(post),
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

  Widget _buildInteractionIcon({
    required IconData icon, 
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 16),
            SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetail(Post post) {
    // Navigate to post detail page
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Container(
            width: 600,
            height: 500,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Spacer(),
                    Text('Post Detail', style: TextStyle(color: Colors.white)),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildPostItem(post),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReplyDialog(Post post) {
    final TextEditingController replyController = TextEditingController();
    
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
                    Text('Reply to ${post.name}', style: TextStyle(color: Colors.white)),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: replyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Post your reply',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (replyController.text.isNotEmpty) {
                          await _apiService.replyToPost(post.id, replyController.text);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reply posted!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: Text('Reply'),
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

  Future<void> _likePost(Post post) async {
    try {
      await _apiService.likePost(post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post liked!')),
      );
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  Future<void> _retweetPost(Post post) async {
    try {
      await _apiService.retweetPost(post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post retweeted!')),
      );
    } catch (e) {
      print('Error retweeting post: $e');
    }
  }

  Future<void> _bookmarkPost(Post post) async {
    try {
      final bookmarked = await _apiService.bookmarkPost(post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookmarked ? 'Post bookmarked!' : 'Bookmark removed!'),
        ),
      );
    } catch (e) {
      print('Error bookmarking post: $e');
    }
  }

  void _sharePost(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality will be implemented')),
    );
  }

  void _showFollowersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Container(
            width: 400,
            height: 500,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Spacer(),
                      Text('Followers', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<User>>(
                    future: _apiService.getFollowers(_profileUser!.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text('No followers yet', style: TextStyle(color: Colors.grey)),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final user = snapshot.data![index];
                          return _buildUserListItem(user);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFollowingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Container(
            width: 400,
            height: 500,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Spacer(),
                      Text('Following', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<User>>(
                    future: _apiService.getFollowing(_profileUser!.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text('Not following anyone yet', style: TextStyle(color: Colors.grey)),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final user = snapshot.data![index];
                          return _buildUserListItem(user);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserListItem(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.profileImage != null
            ? NetworkImage('http://localhost:3000/${user.profileImage}')
            : AssetImage('images/default_avatar.jpg') as ImageProvider,
      ),
      title: Row(
        children: [
          Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
          if (user.isVerified)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.verified, color: Colors.blue, size: 16),
            ),
        ],
      ),
      subtitle: Text('@${user.username}', style: TextStyle(color: Colors.grey)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(userId: user.id),
          ),
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
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => NotificationPage())
              );
            },
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
            isActive: true,
            onTap: () {},
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
              FutureBuilder<List<User>>(
                future: _apiService.getSuggestedUsers(_profileUser!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  
                  return Column(
                    children: snapshot.data!.take(3).map((user) {
                      return _buildFollowSuggestion(user);
                    }).toList(),
                  );
                },
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

  Widget _buildFollowSuggestion(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: user.profileImage != null
                ? NetworkImage('http://localhost:3000/${user.profileImage}')
                : AssetImage('images/default_avatar.jpg') as ImageProvider,
            radius: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _followUser(),
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
      ),
    );
  }

  // Utility functions
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.year}';
  }
}