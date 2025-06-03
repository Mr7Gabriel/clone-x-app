import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'user_provider.dart';
import 'models.dart';
import 'api_service.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'notification_page.dart';
import 'message_page.dart';
import 'bookmark_page.dart';
import 'profile_page.dart';

class PostPage extends StatefulWidget {
  final Post post;

  const PostPage({super.key, required this.post});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _replyController = TextEditingController();
  List<Reply> _replies = [];
  bool _isLoading = true;
  bool _isReplying = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadReplies();
    
    // 🔥 Listener untuk update button state
    _replyController.addListener(() {
      setState(() {
        // Update UI ketika text berubah
      });
    });
  }

  @override
  void dispose() {
    _replyController.removeListener(() {});
    _replyController.dispose();
    super.dispose();
  }

  // 🔥 Helper function untuk check apakah bisa reply
  bool _canReply() {
    return _replyController.text.trim().isNotEmpty || _selectedImage != null;
  }

  Future<void> _loadReplies() async {
    print('=== DEBUG _loadReplies START ===');
    print('Loading replies for post ID: ${widget.post.id}');
    
    setState(() {
      _isLoading = true;
    });

    try {
      final replies = await _apiService.getReplies(widget.post.id);
      print('=== _loadReplies RESULT ===');
      print('Received ${replies.length} replies from API');
      
      for (int i = 0; i < replies.length; i++) {
        print('Reply $i: ID=${replies[i].id}, Content="${replies[i].content}", User=${replies[i].username}');
      }
      
      if (mounted) {
        setState(() {
          _replies = replies;
          _isLoading = false;
        });
        
        print('State updated successfully. _replies.length = ${_replies.length}');
      }
    } catch (e, stackTrace) {
      print('=== _loadReplies ERROR ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load replies: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
    
    print('=== DEBUG _loadReplies END ===');
  }

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reply harus berisi teks atau gambar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isReplying = true;
    });

    try {
      String? imageUrl;
      
      if (_selectedImage != null && await _selectedImage!.exists()) {
        print('Uploading reply image...');
        
        if (kIsWeb) {
          final XFile xFile = XFile(_selectedImage!.path);
          imageUrl = await _apiService.uploadPostImageFromXFile(xFile);
        } else {
          imageUrl = await _apiService.uploadPostImage(_selectedImage!);
        }
        
        if (imageUrl == null) {
          throw Exception('Failed to upload image');
        }
        
        print('Reply image uploaded: $imageUrl');
      }
      
      String replyContent = _replyController.text.trim();
      if (replyContent.isEmpty && imageUrl != null) {
        replyContent = "📷";
      }
      
      print('Posting reply...');
      final reply = await _apiService.replyToPost(
        widget.post.id, 
        replyContent,
        imageUrl: imageUrl
      );
      
      if (reply != null) {
        setState(() {
          _replies.insert(0, reply);
          _replyController.clear();
          _selectedImage = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Reply posted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        throw Exception('Failed to post reply - no response');
      }
    } catch (e) {
      print('Error posting reply: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Failed to post reply: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isReplying = false;
      });
    }
  }

  Future<void> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          if (bytes.isEmpty) {
            throw Exception('Selected image is empty');
          }
          
          setState(() {
            _selectedImage = File(image.path);
          });
        } else {
          final File imageFile = File(image.path);
          if (await imageFile.exists()) {
            setState(() {
              _selectedImage = imageFile;
            });
          } else {
            throw Exception('Image file not accessible');
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected: ${image.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error selecting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReplyToReplyDialog(Reply reply) {
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
                    Expanded(
                      child: Text(
                        'Reply to ${reply.name}',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
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
                      Row(
                        children: [
                          Text(
                            reply.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (reply.isVerified) ...[
                            SizedBox(width: 4),
                            Icon(Icons.verified, color: Colors.blue, size: 16),
                          ],
                          SizedBox(width: 8),
                          Text(
                            '@${reply.username}',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(reply.content),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (replyController.text.trim().isNotEmpty) {
                          try {
                            await _apiService.replyToPost(widget.post.id, replyController.text.trim());
                            Navigator.pop(context);
                            
                            await _loadReplies();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reply posted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to post reply'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: Text('Reply', style: TextStyle(color: Colors.white)),
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

  Future<void> _likeReply(Reply reply) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reply liked!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error liking reply: $e');
    }
  }

  Future<void> _bookmarkReply(Reply reply) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reply bookmarked!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error bookmarking reply: $e');
    }
  }

  void _shareReply(Reply reply) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share reply functionality will be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showMainReplyDialog() {
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
                    Expanded(
                      child: Text(
                        'Reply to ${widget.post.name}',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
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
                        if (replyController.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          _replyController.text = replyController.text;
                          await _postReply();
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

  Future<void> _likeMainPost() async {
    try {
      await _apiService.likePost(widget.post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post liked!')),
      );
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  Future<void> _retweetMainPost() async {
    try {
      await _apiService.retweetPost(widget.post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post retweeted!')),
      );
    } catch (e) {
      print('Error retweeting post: $e');
    }
  }

  Future<void> _bookmarkMainPost() async {
    try {
      await _apiService.bookmarkPost(widget.post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post bookmarked!')),
      );
    } catch (e) {
      print('Error bookmarking post: $e');
    }
  }

  void _shareMainPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality will be implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMainPost(),
                  Divider(color: Colors.grey[800], height: 1),
                  
                  _buildReplyInput(true),
                  
                  Divider(color: Colors.grey[800], height: 1),
                  
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                  else if (_replies.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No replies yet. Be the first to reply!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ..._replies.map((reply) => _buildReplyCard(reply, true)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildMobileBottomNav(context),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          _buildSideNav(),
          
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 30),
                      Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMainPost(),
                        Divider(color: Colors.grey[800], height: 1),
                        
                        _buildReplyInput(false),
                        
                        Divider(color: Colors.grey[800], height: 1),
                        
                        if (_isLoading)
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: Colors.blue),
                          )
                        else if (_replies.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No replies yet. Be the first to reply!',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._replies.map((reply) => _buildReplyCard(reply, false)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (MediaQuery.of(context).size.width > 1000)
            Container(
              width: 350,
              child: _buildRightSidebar(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainPost() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.post.profileImage != null 
                  ? NetworkImage('http://localhost:3000/${widget.post.profileImage}')
                  : AssetImage('images/default_avatar.jpg') as ImageProvider,
                radius: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.post.name ?? 'Unknown User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.post.isVerified == true) ...[
                          SizedBox(width: 4),
                          Icon(Icons.verified, color: Colors.blue, size: 16),
                        ],
                      ],
                    ),
                    Text(
                      '@${widget.post.username ?? 'unknown'}',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          Text(
            widget.post.content,
            style: TextStyle(
              fontSize: 23,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          
          if (widget.post.imageUrl != null) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'http://localhost:3000/${widget.post.imageUrl}',
                fit: BoxFit.cover,
                width: double.infinity,
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
          
          SizedBox(height: 16),
          
          Text(
            '${_formatFullTime(widget.post.createdAt)} · ${_formatViews()} Views',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          
          SizedBox(height: 16),
          Divider(color: Colors.grey[800], height: 1),
          SizedBox(height: 16),
          
          Row(
            children: [
              _buildStatItem('${widget.post.replyCount}', 'replies'),
              SizedBox(width: 20),
              _buildStatItem('${widget.post.retweetCount}', 'reposts'),
              SizedBox(width: 20),
              _buildStatItem('${widget.post.likeCount}', 'likes'),
              SizedBox(width: 20),
              _buildStatItem('${_formatCount(1100)}', 'bookmarks'),
            ],
          ),
          
          SizedBox(height: 16),
          Divider(color: Colors.grey[800], height: 1),
          SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                Icons.chat_bubble_outline, 
                Colors.grey,
                onTap: () => _showMainReplyDialog(),
              ),
              _buildActionButton(
                Icons.repeat, 
                Colors.grey,
                onTap: () => _retweetMainPost(),
              ),
              _buildActionButton(
                Icons.favorite_border, 
                Colors.grey,
                onTap: () => _likeMainPost(),
              ),
              _buildActionButton(
                Icons.bookmark_border, 
                Colors.grey,
                onTap: () => _bookmarkMainPost(),
              ),
              _buildActionButton(
                Icons.share_outlined, 
                Colors.grey,
                onTap: () => _shareMainPost(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: count,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, {VoidCallback? onTap}) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onTap,
    );
  }

  // 🔥 PERBAIKAN REPLY INPUT - Tambahkan onChanged dan gunakan _canReply()
  Widget _buildReplyInput(bool isMobile) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        if (user == null) return SizedBox();

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
                    TextField(
                      controller: _replyController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Post your reply',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      // 🔥 TAMBAHKAN ONCHANGED UNTUK UPDATE STATE
                      onChanged: (value) {
                        setState(() {
                          // Trigger rebuild untuk update button state
                        });
                      },
                    ),
                    
                    if (_selectedImage != null) ...[
                      SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            constraints: BoxConstraints(maxHeight: 200),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb
                                ? Image.network(
                                    _selectedImage!.path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.image_outlined, color: Colors.blue, size: 20),
                          onPressed: _isReplying ? null : _selectImage,
                        ),
                        IconButton(
                          icon: Icon(Icons.gif_box_outlined, color: Colors.blue, size: 20),
                          onPressed: _isReplying ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.poll_outlined, color: Colors.blue, size: 20),
                          onPressed: _isReplying ? null : () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.emoji_emotions_outlined, color: Colors.blue, size: 20),
                          onPressed: _isReplying ? null : () {},
                        ),
                        
                        Spacer(),
                        
                        // 🔥 GUNAKAN _canReply() FUNCTION
                        ElevatedButton(
                          onPressed: _canReply() && !_isReplying ? _postReply : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canReply() ? Colors.blue : Colors.grey[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          ),
                          child: _isReplying
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text('Reply'),
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

  Widget _buildReplyCard(Reply reply, bool isMobile) {
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
            backgroundImage: reply.profileImage != null 
              ? NetworkImage('http://localhost:3000/${reply.profileImage}')
              : AssetImage('images/default_avatar.jpg') as ImageProvider,
            radius: 20,
          ),
          SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    if (reply.isVerified) ...[
                      SizedBox(width: 4),
                      Icon(Icons.verified, color: Colors.blue, size: 15),
                    ],
                    SizedBox(width: 8),
                    Text(
                      '@${reply.username}',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '· ${_formatTime(reply.createdAt)}',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                      onPressed: () {},
                    ),
                  ],
                ),
                
                SizedBox(height: 4),
                
                Text(
                  reply.content,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                
                if (reply.imageUrl != null) ...[
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'http://localhost:3000/${reply.imageUrl}',
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
                
                Row(
                  children: [
                    _buildReplyActionButton(
                      Icons.chat_bubble_outline, 
                      '',
                      onTap: () {
                        print('Reply button pressed for reply: ${reply.id}');
                        _showReplyToReplyDialog(reply);
                      },
                    ),
                    SizedBox(width: 60),
                    
                    _buildReplyActionButton(
                      Icons.repeat, 
                      '',
                      onTap: () {
                        print('Retweet button pressed for reply: ${reply.id}');
                        _likeReply(reply);
                      },
                    ),
                    SizedBox(width: 60),
                    
                    _buildReplyActionButton(
                      Icons.favorite_border, 
                      '',
                      onTap: () {
                        print('Like button pressed for reply: ${reply.id}');
                        _likeReply(reply);
                      },
                    ),
                    SizedBox(width: 60),
                    
                    _buildReplyActionButton(
                      Icons.bookmark_border, 
                      '',
                      onTap: () {
                        print('Bookmark button pressed for reply: ${reply.id}');
                        _bookmarkReply(reply);
                      },
                    ),
                    
                    _buildReplyActionButton(
                      Icons.share_outlined, 
                      '',
                      onTap: () {
                        print('Share button pressed for reply: ${reply.id}');
                        _shareReply(reply);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 PERBAIKAN REPLY ACTION BUTTON
  Widget _buildReplyActionButton(IconData icon, String count, {VoidCallback? onTap}) {
    return InkWell(
      onTap: () {
        print('=== DEBUG: Reply button tapped! ===');
        print('Icon: $icon');
        print('OnTap callback: ${onTap != null ? 'Available' : 'NULL'}');
        
        if (onTap != null) {
          onTap();
        } else {
          print('ERROR: onTap callback is null!');
          if (icon == Icons.chat_bubble_outline) {
            print('Opening reply dialog as fallback...');
            _showMainReplyDialog();
          }
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: icon == Icons.chat_bubble_outline ? Colors.blue : Colors.grey, 
              size: 16
            ),
            if (count.isNotEmpty) ...[
              SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🔥 PERBAIKAN SIDE NAV - BUAT NAVIGASI BERFUNGSI
  Widget _buildSideNav() {
    return Container(
      width: 70,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Icon(Icons.close, color: Colors.white, size: 30),
          SizedBox(height: 30),
          
          // 🔥 NAVIGASI YANG BERFUNGSI
          _buildNavButton(Icons.home, false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }),
          SizedBox(height: 20),
          _buildNavButton(Icons.search, false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ExplorePage()),
            );
          }),
          SizedBox(height: 20),
          _buildNavButton(Icons.notifications_outlined, false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          }),
          SizedBox(height: 20),
          _buildNavButton(Icons.mail_outline, false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MessagePage()),
            );
          }),
          SizedBox(height: 20),
          _buildNavButton(Icons.bookmark_border, false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BookmarkPage()),
            );
          }),
          SizedBox(height: 20),
          _buildNavButton(Icons.person_outline, false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }),
          
          Spacer(),
          
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.currentUser;
              return GestureDetector(
                onTap: () => _showProfileMenu(context),
                child: CircleAvatar(
                  backgroundImage: user?.profileImage != null 
                    ? NetworkImage('http://localhost:3000/${user!.profileImage}')
                    : AssetImage('images/default_avatar.jpg') as ImageProvider,
                  radius: 18,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool isActive, VoidCallback onTap) {
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

  Widget _buildRightSidebar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relevant people',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _buildRelevantPerson(
                  'virgo the ?',
                  '@virgoowitch',
                  'okb vs stj dr',
                  'images/default_avatar.jpg',
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What's happening",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _buildTrendingItem('Going Public', 'LIVE'),
                SizedBox(height: 16),
                _buildTrendingLocation('Trending in Indonesia', 'Wkwk', '63K posts'),
                _buildTrendingLocation('Trending in Indonesia', 'Senin', '115K posts'),
                _buildTrendingLocation('Trending in Indonesia', 'Audinina', '38.9K posts'),
                _buildTrendingLocation('Trending in Indonesia', 'Kalau', '180K posts'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelevantPerson(String name, String username, String subtitle, String imagePath) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                username,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
          child: Text(
            'Follow',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingItem(String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'GP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingLocation(String location, String topic, String count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Text(
            topic,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          Text(
            count,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // 🔥 PERBAIKAN MOBILE BOTTOM NAV - BUAT NAVIGASI BERFUNGSI
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
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
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
                        backgroundImage: user?.profileImage != null 
                          ? NetworkImage('http://localhost:3000/${user!.profileImage}')
                          : AssetImage('images/default_avatar.jpg') as ImageProvider,
                      ),
                      title: Text(
                        user?.name ?? 'Unknown User', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        '@${user?.username ?? 'unknown'}', 
                        style: TextStyle(color: Colors.grey)
                      ),
                      trailing: Icon(Icons.check_circle, color: Colors.blue),
                    ),
                    Divider(color: Colors.grey[800]),
                    _buildProfileMenuItem(
                      'Tambahkan akun yang ada', 
                      () {
                        Navigator.pop(context);
                      }
                    ),
                    _buildProfileMenuItem(
                      'Kelola Akun', 
                      () {
                        Navigator.pop(context);
                      }
                    ),
                    _buildProfileMenuItem(
                      'Keluar', 
                      () {
                        Navigator.pop(context);
                        _showLogoutConfirmation(context);
                      }
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

  Widget _buildProfileMenuItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

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
              onPressed: () async {
                Navigator.pop(context);
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
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

  String _formatFullTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '$displayHour:$minute $period · ${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _formatViews() {
    return '1.2M';
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