import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'notification_page.dart';
import 'message_page.dart';
import 'profile_page.dart';
import 'user_provider.dart';
import 'models.dart';
import 'api_service.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final ApiService _apiService = ApiService();
  
  List<Post> _bookmarks = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser != null) {
        final bookmarks = await _apiService.getBookmarks(currentUser.id);
        setState(() {
          _bookmarks = bookmarks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading bookmarks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshBookmarks() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshBookmarks();
      await _loadBookmarks();
    } catch (e) {
      print('Error refreshing bookmarks: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _removeBookmark(Post post, int index) async {
    try {
      await _apiService.bookmarkPost(post.id);
      setState(() {
        _bookmarks.removeAt(index);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bookmark dihapus'),
          backgroundColor: Colors.grey[700],
          action: SnackBarAction(
            label: 'Urungkan',
            textColor: Colors.blue,
            onPressed: () {
              _undoRemoveBookmark(post, index);
            },
          ),
        ),
      );
    } catch (e) {
      print('Error removing bookmark: $e');
    }
  }

  Future<void> _undoRemoveBookmark(Post post, int index) async {
    try {
      await _apiService.bookmarkPost(post.id);
      setState(() {
        _bookmarks.insert(index, post);
      });
    } catch (e) {
      print('Error undoing bookmark removal: $e');
    }
  }

  Future<void> _likePost(Post post, int index) async {
    try {
      final liked = await _apiService.likePost(post.id);
      setState(() {
        _bookmarks[index] = Post(
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

  Future<void> _retweetPost(Post post, int index) async {
    try {
      final retweeted = await _apiService.retweetPost(post.id);
      setState(() {
        _bookmarks[index] = Post(
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
      });
    } catch (e) {
      print('Error retweeting post: $e');
    }
  }

  Future<void> _replyToPost(Post post) async {
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
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[800]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${post.name} @${post.username}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(post.content),
                    ],
                  ),
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
            onPressed: () => _showBookmarkOptions(context),
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
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final user = userProvider.currentUser;
                              return Text(
                                '@${user?.username ?? 'unknown'}',
                                style: TextStyle(color: Colors.grey),
                              );
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () => _showBookmarkOptions(context),
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

  Widget _buildBookmarkContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (_bookmarks.isEmpty) {
      return _buildEmptyBookmarkState();
    }

    return RefreshIndicator(
      onRefresh: _refreshBookmarks,
      color: Colors.blue,
      child: ListView.builder(
        itemCount: _bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = _bookmarks[index];
          return _buildBookmarkItem(bookmark, index);
        },
      ),
    );
  }

  Widget _buildEmptyBookmarkState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Belum ada Bookmark',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Ketuk ikon bookmark pada postingan untuk menambahkan ke daftar favorit Anda.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Jelajahi Postingan'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkItem(Post bookmark, int index) {
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: bookmark.userId),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: bookmark.profileImage != null
                      ? NetworkImage('http://localhost:3000/${bookmark.profileImage}')
                      : AssetImage('images/default_avatar.jpg') as ImageProvider,
                  radius: 20,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(userId: bookmark.userId),
                              ),
                            );
                          },
                          child: Text(
                            bookmark.name ?? 'Unknown User',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (bookmark.isVerified == true)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.verified, color: Colors.blue, size: 16),
                          ),
                        SizedBox(width: 4),
                        Text(
                          '@${bookmark.username ?? 'unknown'}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          ' · ${_formatTime(bookmark.createdAt)}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Spacer(),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                          color: Colors.grey[900],
                          onSelected: (value) => _handlePostAction(value, bookmark, index),
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'remove_bookmark',
                              child: Row(
                                children: [
                                  Icon(Icons.bookmark_remove, color: Colors.white, size: 20),
                                  SizedBox(width: 12),
                                  Text('Hapus bookmark', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share, color: Colors.white, size: 20),
                                  SizedBox(width: 12),
                                  Text('Bagikan postingan', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'copy_link',
                              child: Row(
                                children: [
                                  Icon(Icons.link, color: Colors.white, size: 20),
                                  SizedBox(width: 12),
                                  Text('Salin tautan', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(bookmark.content, style: TextStyle(fontSize: 15)),
                    if (bookmark.imageUrl != null) ...[
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _showImageDetail(bookmark.imageUrl!),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'http://localhost:3000/${bookmark.imageUrl}',
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
                      ),
                    ],
                    SizedBox(height: 12),
                    // Interaction icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInteractionIcon(
                          icon: Icons.chat_bubble_outline,
                          count: bookmark.replyCount,
                          onTap: () => _replyToPost(bookmark),
                        ),
                        _buildInteractionIcon(
                          icon: Icons.repeat,
                          count: bookmark.retweetCount,
                          onTap: () => _retweetPost(bookmark, index),
                        ),
                        _buildInteractionIcon(
                          icon: Icons.favorite_border,
                          count: bookmark.likeCount,
                          onTap: () => _likePost(bookmark, index),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.bookmark,
                              color: Colors.blue,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.share_outlined, color: Colors.grey, size: 16),
                              onPressed: () => _sharePost(bookmark),
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

  void _handlePostAction(String action, Post bookmark, int index) {
    switch (action) {
      case 'remove_bookmark':
        _removeBookmark(bookmark, index);
        break;
      case 'share':
        _sharePost(bookmark);
        break;
      case 'copy_link':
        _copyPostLink(bookmark);
        break;
    }
  }

  void _sharePost(Post bookmark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality will be implemented')),
    );
  }

  void _copyPostLink(Post bookmark) {
    // Implement copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _showImageDetail(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              child: Image.network(
                'http://localhost:3000/$imageUrl',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBookmarkOptions(BuildContext context) {
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
                leading: Icon(Icons.delete_outline, color: Colors.white),
                title: Text('Hapus semua Bookmark', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAllConfirmation();
                },
              ),
              ListTile(
                leading: Icon(Icons.folder_outlined, color: Colors.white),
                title: Text('Tambahkan Bookmark ke daftar', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateListDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.white),
                title: Text('Bagikan Bookmark', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _shareBookmarks();
                },
              ),
              ListTile(
                leading: Icon(Icons.sort, color: Colors.white),
                title: Text('Urutkan Bookmark', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSortOptions();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Hapus Semua Bookmark?', style: TextStyle(color: Colors.white)),
          content: Text(
            'Tindakan ini tidak dapat dibatalkan. Semua bookmark akan dihapus permanen.',
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
                await _deleteAllBookmarks();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Hapus Semua'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllBookmarks() async {
    try {
      // Remove all bookmarks one by one
      for (final bookmark in _bookmarks) {
        await _apiService.bookmarkPost(bookmark.id);
      }
      
      setState(() {
        _bookmarks.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua bookmark telah dihapus')),
      );
    } catch (e) {
      print('Error deleting all bookmarks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus bookmark'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreateListDialog() {
    final TextEditingController listNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Buat Daftar Bookmark', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: listNameController,
                decoration: InputDecoration(
                  hintText: 'Nama daftar',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Fitur daftar bookmark akan segera tersedia.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur daftar bookmark akan segera tersedia')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Buat'),
            ),
          ],
        );
      },
    );
  }

  void _shareBookmarks() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share bookmarks functionality will be implemented')),
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Urutkan Bookmark', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Terbaru', style: TextStyle(color: Colors.white)),
                leading: Radio(
                  value: 'newest',
                  groupValue: 'newest',
                  onChanged: (value) {},
                  activeColor: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Terlama', style: TextStyle(color: Colors.white)),
                leading: Radio(
                  value: 'oldest',
                  groupValue: 'newest',
                  onChanged: (value) {},
                  activeColor: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Paling Disukai', style: TextStyle(color: Colors.white)),
                leading: Radio(
                  value: 'most_liked',
                  groupValue: 'newest',
                  onChanged: (value) {},
                  activeColor: Colors.blue,
                ),
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
            isActive: true,
            onTap: () {},
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
        // Bookmark stats
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
                'Statistik Bookmark',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total bookmark:', style: TextStyle(color: Colors.grey)),
                  Text(
                    '${_bookmarks.length}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dengan gambar:', style: TextStyle(color: Colors.grey)),
                  Text(
                    '${_bookmarks.where((b) => b.imageUrl != null).length}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bulan ini:', style: TextStyle(color: Colors.grey)),
                  Text(
                    '${_getThisMonthBookmarks()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Premium Box
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
                'Berlangganan Premium',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Dapatkan fitur bookmark lanjutan dan organisasi yang lebih baik.',
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

  int _getThisMonthBookmarks() {
    final now = DateTime.now();
    return _bookmarks.where((bookmark) {
      return bookmark.createdAt.year == now.year && 
             bookmark.createdAt.month == now.month;
    }).length;
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