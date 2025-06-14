import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // TAMBAHKAN INI UNTUK kIsWeb
import 'dart:io';
import 'dart:typed_data'; // TAMBAHKAN INI UNTUK Uint8List
import 'profile_page.dart';
import 'explore_page.dart';
import 'notification_page.dart';
import 'message_page.dart';
import 'bookmark_page.dart';
import 'user_provider.dart';
import 'models.dart';
import 'api_service.dart';
import 'post_page.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await _apiService.getPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final posts = await _apiService.getPosts();
      setState(() {
        _posts = posts;
        _isRefreshing = false;
      });
    } catch (e) {
      print('Error refreshing posts: $e');
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _createPost(String content, {String? imageUrl}) async {
    try {
      // PERBAIKAN: Validasi input - jika content kosong, kasih placeholder
      String finalContent = content.trim();
      if (finalContent.isEmpty && imageUrl != null) {
        finalContent = "📷"; // Emoji placeholder jika hanya upload gambar
      }

      // Validasi: harus ada content atau gambar
      if (finalContent.isEmpty && imageUrl == null) {
        throw Exception('Posting harus berisi teks atau gambar');
      }

      print('DEBUG: Creating post with content: "$finalContent"');
      print('DEBUG: Image URL: $imageUrl');

      final post = await _apiService.createPost(
        finalContent,
        imageUrl: imageUrl,
      );

      if (post != null) {
        setState(() {
          _posts.insert(0, post);
        });

        print('DEBUG: Post created successfully');
      } else {
        throw Exception('Failed to create post - no response from server');
      }
    } catch (e) {
      print('ERROR: Create post failed: $e');
      rethrow; // Re-throw error agar bisa ditangkap di caller
    }
  }

  Future<void> _likePost(int postId, int index) async {
    try {
      final liked = await _apiService.likePost(postId);
      setState(() {
        final post = _posts[index];
        _posts[index] = Post(
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
      });
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  Future<void> _retweetPost(int postId, int index) async {
    try {
      final retweeted = await _apiService.retweetPost(postId);
      setState(() {
        final post = _posts[index];
        _posts[index] = Post(
          id: post.id,
          userId: post.userId,
          content: post.content,
          imageUrl: post.imageUrl,
          likeCount: post.likeCount,
          retweetCount:
              retweeted ? post.retweetCount + 1 : post.retweetCount - 1,
          replyCount: post.replyCount,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          username: post.username,
          name: post.name,
          profileImage: post.profileImage,
          isVerified: post.isVerified,
        );
      });
    } catch (e) {
      print('Error retweeting post: $e');
    }
  }

  Future<void> _bookmarkPost(int postId) async {
    try {
      final bookmarked = await _apiService.bookmarkPost(postId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookmarked ? 'Post bookmarked!' : 'Bookmark removed!'),
          backgroundColor: bookmarked ? Colors.green : Colors.grey,
        ),
      );
    } catch (e) {
      print('Error bookmarking post: $e');
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
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: [Tab(text: "For you"), Tab(text: "Following")],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsList(),
            Center(child: Text("Following posts will be implemented soon")),
          ],
        ),
        bottomNavigationBar: _buildMobileBottomNav(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showPostDialog(context);
          },
          backgroundColor: Colors.blue,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side navigation bar
            _buildSideNav(context),

            // Main feed section
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
                      controller: _tabController,
                      tabs: [Tab(text: "Untuk Anda"), Tab(text: "Mengikuti")],
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
                  ),

                  // Input posting area
                  _buildCreatePostSection(),

                  // Post list
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPostsList(),
                        Center(
                          child: Text(
                            "Following posts will be implemented soon",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right sidebar
            if (MediaQuery.of(context).size.width > 1000)
              Container(width: 350, child: _buildRightSidebar()),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        if (user == null) return SizedBox();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage:
                    user.profileImage != null
                        ? NetworkImage(
                          'http://localhost:3000/${user.profileImage}',
                        )
                        : AssetImage('images/default_avatar.jpg')
                            as ImageProvider,
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showPostDialog(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Apa yang sedang terjadi?",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.image, color: Colors.blue, size: 20),
                          onPressed: () => _showPostDialog(context),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.gif_box,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => _showPostDialog(context),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.bar_chart,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => _showPostDialog(context),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => _showPostDialog(context),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => _showPostDialog(context),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _showPostDialog(context),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _showPostDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
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
        );
      },
    );
  }

  Widget _buildPostsList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to post something!',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      color: Colors.blue,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post, index);
        },
      ),
    );
  }

  Widget _buildPostCard(Post post, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to PostPage when post is tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostPage(post: post)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage:
                    post.profileImage != null
                        ? NetworkImage(
                          'http://localhost:3000/${post.profileImage}',
                        )
                        : AssetImage('images/default_avatar.jpg')
                            as ImageProvider,
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
                            post.name ?? 'Unknown User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.isVerified == true)
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 15,
                            ),
                          ),
                        SizedBox(width: 4),
                        Text(
                          '@${post.username ?? 'unknown'}',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Text(
                          " · ${_formatTime(post.createdAt)}",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _showPostOptions(context, post),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Content
                    Text(post.content, style: TextStyle(fontSize: 15)),

                    // Image if any
                    if (post.imageUrl != null) ...[
                      const SizedBox(height: 8),
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
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Interaction icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInteractionButton(
                          icon: Icons.chat_bubble_outline,
                          count: post.replyCount,
                          onTap: () => _showReplyDialog(context, post),
                        ),
                        _buildInteractionButton(
                          icon: Icons.repeat,
                          count: post.retweetCount,
                          onTap: () => _retweetPost(post.id, index),
                          color: Colors.green,
                        ),
                        _buildInteractionButton(
                          icon: Icons.favorite_border,
                          count: post.likeCount,
                          onTap: () => _likePost(post.id, index),
                          color: Colors.red,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.bookmark_border,
                                color: Colors.grey,
                                size: 18,
                              ),
                              onPressed: () => _bookmarkPost(post.id),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.share_outlined,
                                color: Colors.grey,
                                size: 18,
                              ),
                              onPressed: () => _sharePost(post),
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
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    Color color = Colors.grey,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    File? selectedImage;
    XFile? selectedXFile; // Untuk web compatibility
    bool isPosting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool canPost() {
              bool hasText = contentController.text.trim().isNotEmpty;
              bool hasImage = selectedImage != null;
              
              return hasText || hasImage;
            }

            // Fungsi select image yang support web
            Future<void> _selectImageForDialog() async {
              try {
                print('=== Starting image selection (Web Compatible) ===');

                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1920,
                  maxHeight: 1080,
                  imageQuality: 85,
                );

                if (image != null) {
                  print('Image selected: ${image.name}');
                  print('Image path: ${image.path}');

                  if (kIsWeb) {
                    // Untuk web: baca bytes untuk validasi
                    final bytes = await image.readAsBytes();
                    print('Web - Image size: ${bytes.length} bytes');

                    if (bytes.isEmpty) {
                      throw Exception('Selected image is empty');
                    }

                    // Validasi ukuran file (max 10MB)
                    final fileSizeInMB = bytes.length / (1024 * 1024);
                    if (fileSizeInMB > 10) {
                      throw Exception('Image too large. Max 10MB allowed.');
                    }

                    setState(() {
                      selectedXFile = image; // Simpan XFile untuk web upload
                      selectedImage = File(
                        image.path,
                      ); // Untuk UI preview (blob URL)
                    });
                  } else {
                    // Untuk mobile: gunakan file path normal
                    final File imageFile = File(image.path);

                    if (await imageFile.exists()) {
                      // Validasi ukuran file
                      final fileSize = await imageFile.length();
                      final fileSizeInMB = fileSize / (1024 * 1024);
                      if (fileSizeInMB > 10) {
                        throw Exception('Image too large. Max 10MB allowed.');
                      }

                      setState(() {
                        selectedImage = imageFile;
                        selectedXFile = image;
                      });
                    } else {
                      throw Exception('Image file not accessible');
                    }
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Image selected: ${image.name}'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  print('No image selected');
                }
              } catch (e) {
                print('Error selecting image: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to select image: $e'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            }

            return Dialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
              child: Container(
                width: 500,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed:
                              isPosting ? null : () => Navigator.pop(context),
                        ),
                        Spacer(),
                        Text(
                          'Drafts',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ],
                    ),

                    // Content area
                    Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile picture
                            Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                final user = userProvider.currentUser;
                                return CircleAvatar(
                                  backgroundImage:
                                      user?.profileImage != null
                                          ? NetworkImage(
                                            'http://localhost:3000/${user!.profileImage}',
                                          )
                                          : AssetImage(
                                                'images/default_avatar.jpg',
                                              )
                                              as ImageProvider,
                                  radius: 20,
                                );
                              },
                            ),
                            SizedBox(width: 12),

                            // Input area
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text input
                                  TextField(
                                    controller: contentController,
                                    maxLines: null,
                                    minLines: 3,
                                    decoration: InputDecoration(
                                      hintText: 'What is happening?!',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),

                                  // Selected image preview
                                  if (selectedImage != null) ...[
                                    SizedBox(height: 16),
                                    Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          constraints: BoxConstraints(
                                            maxHeight: 300,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child:
                                                kIsWeb
                                                    ? Image.network(
                                                      selectedImage!
                                                          .path, // Blob URL untuk web
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          height: 200,
                                                          color:
                                                              Colors.grey[800],
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  size: 48,
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Failed to load image',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                    : Image.file(
                                                      selectedImage!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          height: 200,
                                                          color:
                                                              Colors.grey[800],
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  size: 48,
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Failed to load image',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedImage = null;
                                                selectedXFile = null;
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.7,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom toolbar
                    Divider(color: Colors.grey[800], height: 1),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        // Media buttons
                        IconButton(
                          icon: Icon(
                            Icons.image_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isPosting ? null : _selectImageForDialog,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.gif_box_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isPosting ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.poll_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isPosting ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isPosting ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.schedule_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isPosting ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.location_on_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isPosting ? null : () {},
                        ),

                        Spacer(),

                        // Character counter
                        if (contentController.text.isNotEmpty) ...[
                          Text(
                            '${contentController.text.length}/280',
                            style: TextStyle(
                              color:
                                  contentController.text.length > 280
                                      ? Colors.red
                                      : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 16),
                        ],

                        // Post button
                        ElevatedButton(
                          onPressed:
                              (canPost() && !isPosting)
                                  ? () async {
                                    setState(() {
                                      isPosting = true;
                                    });

                                    try {
                                      String? imageUrl;

                                      // Upload image jika ada
                                      if (selectedXFile != null) {
                                        print('=== Starting image upload ===');
                                        print(
                                          'Platform: ${kIsWeb ? "Web" : "Mobile"}',
                                        );

                                        imageUrl = await _apiService
                                            .uploadPostImageFromXFile(
                                              selectedXFile!,
                                            );

                                        if (imageUrl == null) {
                                          throw Exception(
                                            'Failed to upload image - no URL returned',
                                          );
                                        }

                                        print(
                                          'Image uploaded successfully: $imageUrl',
                                        );
                                      }

                                      // PERBAIKAN: Validasi content sebelum create post
                                      String postContent =
                                          contentController.text.trim();
                                      if (postContent.isEmpty &&
                                          imageUrl == null) {
                                        throw Exception(
                                          'Posting harus berisi teks atau gambar',
                                        );
                                      }

                                      // Create post
                                      print('Creating post...');
                                      await _createPost(
                                        postContent,
                                        imageUrl: imageUrl,
                                      );

                                      // PERBAIKAN: Tutup dialog DULU sebelum show snackbar
                                      Navigator.pop(context);

                                      // DELAY SEDIKIT BIAR SCAFFOLD READY
                                      await Future.delayed(
                                        Duration(milliseconds: 100),
                                      );

                                      // Show success message
                                      if (mounted) {
                                        // Check if widget still mounted
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Post berhasil dibuat!'),
                                              ],
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      print(
                                        '=== ERROR: Post creation failed ===',
                                      );
                                      print('Error: $e');

                                      // PERBAIKAN: Tutup dialog dulu kalau ada error juga
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }

                                      // DELAY SEDIKIT BIAR SCAFFOLD READY
                                      await Future.delayed(
                                        Duration(milliseconds: 100),
                                      );

                                      // Show error message
                                      if (mounted) {
                                        // Check if widget still mounted
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.error,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Gagal membuat post: $e',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 5),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      // Reset state hanya jika dialog masih ada
                                      if (mounted) {
                                        setState(() {
                                          isPosting = false;
                                        });
                                      }
                                    }
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                canPost() ? Colors.blue : Colors.grey[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            elevation: 0,
                          ),
                          child:
                              isPosting
                                  ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    'Post',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReplyDialog(BuildContext context, Post post) {
    final TextEditingController replyController = TextEditingController();
    File? selectedImage;
    bool isReplying = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool canReply() {
              return replyController.text.trim().isNotEmpty ||
                  selectedImage != null;
            }

            return Dialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
              child: Container(
                width: 500,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed:
                              isReplying ? null : () => Navigator.pop(context),
                        ),
                        Spacer(),
                        Text(
                          'Drafts',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Content area
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Original post
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          post.profileImage != null
                                              ? NetworkImage(
                                                'http://localhost:3000/${post.profileImage}',
                                              )
                                              : AssetImage(
                                                    'images/default_avatar.jpg',
                                                  )
                                                  as ImageProvider,
                                      radius: 20,
                                    ),
                                    Container(
                                      width: 2,
                                      height: 40,
                                      color: Colors.grey[700],
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // User info
                                      Row(
                                        children: [
                                          Text(
                                            post.name ?? 'Unknown User',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (post.isVerified == true) ...[
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.verified,
                                              color: Colors.blue,
                                              size: 16,
                                            ),
                                          ],
                                          SizedBox(width: 8),
                                          Text(
                                            '@${post.username}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '· ${_formatTime(post.createdAt)}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),

                                      // Original post content
                                      Text(
                                        post.content,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),

                                      SizedBox(height: 12),

                                      // Replying to indicator
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                          children: [
                                            TextSpan(text: 'Replying to '),
                                            TextSpan(
                                              text: '@${post.username}',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),

                            // Reply input area
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer<UserProvider>(
                                  builder: (context, userProvider, child) {
                                    final user = userProvider.currentUser;
                                    return CircleAvatar(
                                      backgroundImage:
                                          user?.profileImage != null
                                              ? NetworkImage(
                                                'http://localhost:3000/${user!.profileImage}',
                                              )
                                              : AssetImage(
                                                    'images/default_avatar.jpg',
                                                  )
                                                  as ImageProvider,
                                      radius: 20,
                                    );
                                  },
                                ),
                                SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Reply text input
                                      TextField(
                                        controller: replyController,
                                        maxLines: null,
                                        minLines: 3,
                                        decoration: InputDecoration(
                                          hintText: 'Post your reply',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),

                                      // Selected image preview for reply
                                      if (selectedImage != null) ...[
                                        SizedBox(height: 16),
                                        Stack(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              constraints: BoxConstraints(
                                                maxHeight: 300,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.file(
                                                  selectedImage!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      height: 200,
                                                      color: Colors.grey[800],
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedImage = null;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom toolbar
                    Divider(color: Colors.grey[800], height: 1),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        // Media buttons
                        IconButton(
                          icon: Icon(
                            Icons.image_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed:
                              isReplying
                                  ? null
                                  : () async {
                                    try {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image = await picker
                                          .pickImage(
                                            source: ImageSource.gallery,
                                            maxWidth: 1920,
                                            maxHeight: 1080,
                                            imageQuality: 85,
                                          );

                                      if (image != null) {
                                        final File imageFile = File(image.path);
                                        if (await imageFile.exists()) {
                                          setState(() {
                                            selectedImage = imageFile;
                                          });
                                        }
                                      }
                                    } catch (e) {
                                      print('Error selecting image: $e');
                                    }
                                  },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.gif_box_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isReplying ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.poll_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isReplying ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isReplying ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.schedule_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isReplying ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.location_on_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: isReplying ? null : () {},
                        ),

                        Spacer(),

                        // Character counter
                        if (replyController.text.isNotEmpty) ...[
                          Text(
                            '${replyController.text.length}/280',
                            style: TextStyle(
                              color:
                                  replyController.text.length > 280
                                      ? Colors.red
                                      : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 16),
                        ],

                        // Reply button
                        ElevatedButton(
                          onPressed:
                              (canReply() && !isReplying)
                                  ? () async {
                                    setState(() {
                                      isReplying = true;
                                    });

                                    try {
                                      String? imageUrl;

                                      // Upload image if selected
                                      if (selectedImage != null &&
                                          await selectedImage!.exists()) {
                                        imageUrl = await _apiService
                                            .uploadPostImage(selectedImage!);
                                      }

                                      // Send reply
                                      final reply = await _apiService
                                          .replyToPost(
                                            post.id,
                                            replyController.text.trim(),
                                            imageUrl: imageUrl,
                                          );

                                      if (reply != null) {
                                        // Close dialog first
                                        Navigator.pop(context);

                                        // Show success message
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Your reply was sent'),
                                              ],
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 3),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );

                                        // Update post reply count
                                        setState(() {
                                          final postIndex = _posts.indexWhere(
                                            (p) => p.id == post.id,
                                          );
                                          if (postIndex != -1) {
                                            final updatedPost = Post(
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
                                            _posts[postIndex] = updatedPost;
                                          }
                                        });
                                      } else {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to send reply. Please try again.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      print('Error posting reply: $e');
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to send reply: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                canReply() ? Colors.blue : Colors.grey[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            elevation: 0,
                          ),
                          child:
                              isReplying
                                  ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    'Reply',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPostOptions(BuildContext context, Post post) {
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
                leading: Icon(Icons.bookmark_border, color: Colors.white),
                title: Text(
                  'Bookmark Post',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _bookmarkPost(post.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.white),
                title: Text(
                  'Share Post',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _sharePost(post);
                },
              ),
              ListTile(
                leading: Icon(Icons.copy, color: Colors.white),
                title: Text('Copy Link', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Copy link functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sharePost(Post post) {
    // Share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality will be implemented')),
    );
  }

  Widget _buildSideNav(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[800]!, width: 0.5)),
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

          _buildNavButton(icon: Icons.home, isActive: true, onTap: () {}),
          const SizedBox(height: 22),

          _buildNavButton(
            icon: Icons.search,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ExplorePage()),
              );
            },
          ),
          const SizedBox(height: 25),

          _buildNavButton(
            icon: Icons.notifications_outlined,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
          const SizedBox(height: 25),

          _buildNavButton(
            icon: Icons.mail_outline,
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MessagePage()),
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
                MaterialPageRoute(builder: (context) => BookmarkPage()),
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
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => _showPostDialog(context),
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
              return GestureDetector(
                onTap: () => _showProfileMenu(context),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      user?.profileImage != null
                          ? NetworkImage(
                            'http://localhost:3000/${user!.profileImage}',
                          )
                          : AssetImage('images/default_avatar.jpg')
                              as ImageProvider,
                ),
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
              icon: Icon(Icons.home, color: Colors.blue, size: 26),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.grey, size: 26),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ExplorePage()),
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
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.grey,
                    size: 26,
                  ),
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
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.mail_outline, color: Colors.grey, size: 26),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MessagePage()),
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
        // Search bar
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
                  child: Text("Cari", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumBox(),
                  const SizedBox(height: 16),
                  _buildTrendingWidget(),
                  const SizedBox(height: 16),
                  _buildFollowSuggestions(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumBox() {
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingWidget() {
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
          // Trending topics will be loaded from API
          _buildTrendingItem('Flutter Development', '5.2K posts'),
          _buildTrendingItem('React Native', '3.8K posts'),
          _buildTrendingItem('Mobile Apps', '12.1K posts'),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(String topic, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending in Technology',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: 2),
          Text(
            topic,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(count, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFollowSuggestions() {
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
          // Follow suggestions will be loaded from API
          _buildFollowSuggestion(
            'Flutter Dev',
            '@flutterdev',
            'images/user1.jpg',
          ),
          _buildFollowSuggestion('Dart Lang', '@dart_lang', 'images/user2.jpg'),
          _buildFollowSuggestion(
            'Google Dev',
            '@googledev',
            'images/user3.jpg',
          ),
          SizedBox(height: 16),
          Text('Tampilkan lebih banyak', style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildFollowSuggestion(
    String name,
    String username,
    String imagePath,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: AssetImage(imagePath), radius: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  username,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Follow user functionality
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Following $name')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Ikuti',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.currentUser;

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
                        backgroundImage:
                            user?.profileImage != null
                                ? NetworkImage(
                                  'http://localhost:3000/${user!.profileImage}',
                                )
                                : AssetImage('images/default_avatar.jpg')
                                    as ImageProvider,
                      ),
                      title: Text(
                        user?.name ?? 'Unknown User',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '@${user?.username ?? 'unknown'}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: Icon(Icons.check_circle, color: Colors.blue),
                    ),
                    Divider(color: Colors.grey[800]),
                    _buildProfileMenuItem('Tambahkan akun yang ada', () {
                      Navigator.pop(context);
                      // Handle add existing account
                    }),
                    _buildProfileMenuItem('Kelola Akun', () {
                      Navigator.pop(context);
                      // Handle manage accounts
                    }),
                    _buildProfileMenuItem('Keluar', () {
                      Navigator.pop(context);
                      _showLogoutConfirmation(context);
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileMenuItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Keluar dari akun Anda?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Anda dapat masuk kembali kapan saja.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                await userProvider.logout();
                // Navigate to login screen
                Navigator.of(context).pushReplacementNamed('/auth');
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
}
