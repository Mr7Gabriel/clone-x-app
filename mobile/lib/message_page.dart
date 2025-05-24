import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'home_page.dart';
import 'explore_page.dart';
import 'notification_page.dart';
import 'bookmark_page.dart';
import 'profile_page.dart';
import 'user_provider.dart';
import 'models.dart';
import 'api_service.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Message> _conversations = [];
  List<User> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isRefreshing = false;
  
  User? _selectedUser;
  List<Message> _currentConversation = [];
  bool _isLoadingConversation = false;
  
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchUsers(_searchController.text);
      } else {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser != null) {
        final conversations = await _apiService.getMessages(currentUser.id);
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshConversations() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshMessages();
      await _loadConversations();
    } catch (e) {
      print('Error refreshing conversations: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final users = await _apiService.searchUsers(query);
      setState(() {
        _searchResults = users;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _loadConversation(User user) async {
    setState(() {
      _selectedUser = user;
      _isLoadingConversation = true;
      _currentConversation.clear();
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser != null) {
        final messages = await _apiService.getConversationMessages(currentUser.id, user.id);
        setState(() {
          _currentConversation = messages;
          _isLoadingConversation = false;
        });
      }
    } catch (e) {
      print('Error loading conversation: $e');
      setState(() {
        _isLoadingConversation = false;
      });
    }
  }

  Future<void> _sendMessage(String content) async {
    if (_selectedUser == null || content.trim().isEmpty) return;

    try {
      final message = await _apiService.sendMessage(_selectedUser!.id, content.trim());
      if (message != null) {
        setState(() {
          _currentConversation.add(message);
        });
        
        // Update conversations list
        await _loadConversations();
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
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
    if (_selectedUser != null) {
      return _buildConversationScreen();
    }

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
              onPressed: () => _showMessageSettings(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Messages List
          Expanded(
            child: _isSearching || _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildConversationsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageDialog(),
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
                            onPressed: () => _showMessageSettings(),
                            color: Colors.white,
                          ),
                          IconButton(
                            icon: Icon(Icons.add_comment),
                            onPressed: () => _showNewMessageDialog(),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Search Messages
                _buildSearchBar(),
                
                // Messages List
                Expanded(
                  child: _isSearching || _searchController.text.isNotEmpty
                      ? _buildSearchResults()
                      : _buildConversationsList(),
                ),
              ],
            ),
          ),
          
          // Selected conversation or welcome screen
          Expanded(
            flex: 5,
            child: _selectedUser != null
                ? _buildConversationPanel()
                : _buildWelcomeScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Cari Direct Messages",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults.clear();
                        _isSearching = false;
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada pengguna ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserSearchItem(user);
      },
    );
  }

  Widget _buildUserSearchItem(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.profileImage != null
            ? NetworkImage('http://localhost:3000/${user.profileImage}')
            : AssetImage('images/default_avatar.jpg') as ImageProvider,
        radius: 24,
      ),
      title: Row(
        children: [
          Text(
            user.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (user.isVerified)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.verified, color: Colors.blue, size: 16),
            ),
        ],
      ),
      subtitle: Text(
        '@${user.username}',
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () => _loadConversation(user),
    );
  }

  Widget _buildConversationsList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (_conversations.isEmpty) {
      return _buildEmptyMessagesState();
    }

    return RefreshIndicator(
      onRefresh: _refreshConversations,
      color: Colors.blue,
      child: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final message = _conversations[index];
          return _buildConversationItem(message);
        },
      ),
    );
  }

  Widget _buildEmptyMessagesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada pesan',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Mulai percakapan dengan mengirim pesan kepada seseorang.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showNewMessageDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Tulis Pesan'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(Message message) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    
    // Determine if this is a sent or received message
    final isFromCurrentUser = message.senderId == currentUser?.id;
    final otherUserName = isFromCurrentUser ? 'You' : (message.senderName ?? 'Unknown');
    final otherUserUsername = isFromCurrentUser ? currentUser?.username : (message.senderUsername ?? 'unknown');
    final profileImage = isFromCurrentUser ? currentUser?.profileImage : message.senderProfileImage;

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
            backgroundImage: profileImage != null
                ? NetworkImage('http://localhost:3000/$profileImage')
                : AssetImage('images/default_avatar.jpg') as ImageProvider,
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
                            otherUserName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (message.senderIsVerified == true && !isFromCurrentUser)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified, color: Colors.blue, size: 16),
                            ),
                          SizedBox(width: 4),
                          Text(
                            '@$otherUserUsername',
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  message.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: message.isRead ? Colors.grey[400] : Colors.white,
                    fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!message.isRead && !isFromCurrentUser)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConversationScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedUser = null;
              _currentConversation.clear();
            });
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: _selectedUser!.profileImage != null
                  ? NetworkImage('http://localhost:3000/${_selectedUser!.profileImage}')
                  : AssetImage('images/default_avatar.jpg') as ImageProvider,
              radius: 16,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _selectedUser!.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (_selectedUser!.isVerified)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified, color: Colors.blue, size: 16),
                        ),
                    ],
                  ),
                  Text(
                    '@${_selectedUser!.username}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showUserInfo(_selectedUser!),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildConversationMessages(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildConversationPanel() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Conversation header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: _selectedUser!.profileImage != null
                      ? NetworkImage('http://localhost:3000/${_selectedUser!.profileImage}')
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
                            _selectedUser!.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (_selectedUser!.isVerified)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified, color: Colors.blue, size: 16),
                            ),
                        ],
                      ),
                      Text(
                        '@${_selectedUser!.username}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () => _showUserInfo(_selectedUser!),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: _buildConversationMessages(),
          ),
          
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildConversationMessages() {
    if (_isLoadingConversation) {
      return Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (_currentConversation.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: _selectedUser!.profileImage != null
                  ? NetworkImage('http://localhost:3000/${_selectedUser!.profileImage}')
                  : AssetImage('images/default_avatar.jpg') as ImageProvider,
              radius: 40,
            ),
            SizedBox(height: 16),
            Text(
              _selectedUser!.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '@${_selectedUser!.username}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'Mulai percakapan dengan ${_selectedUser!.name}',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.all(16),
      itemCount: _currentConversation.length,
      itemBuilder: (context, index) {
        final message = _currentConversation[_currentConversation.length - 1 - index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    final isFromCurrentUser = message.senderId == currentUser?.id;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              backgroundImage: message.senderProfileImage != null
                  ? NetworkImage('http://localhost:3000/${message.senderProfileImage}')
                  : AssetImage('images/default_avatar.jpg') as ImageProvider,
              radius: 16,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromCurrentUser ? Colors.blue : Colors.grey[800],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isFromCurrentUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundImage: currentUser?.profileImage != null
                  ? NetworkImage('http://localhost:3000/${currentUser!.profileImage}')
                  : AssetImage('images/default_avatar.jpg') as ImageProvider,
              radius: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final TextEditingController messageController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: null,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  _sendMessage(text);
                  messageController.clear();
                }
              },
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (messageController.text.trim().isNotEmpty) {
                _sendMessage(messageController.text);
                messageController.clear();
              }
            },
            icon: Icon(Icons.send, color: Colors.blue),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.1),
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Container(
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
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showNewMessageDialog(),
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
    );
  }

  void _showNewMessageDialog() {
    final TextEditingController searchController = TextEditingController();
    List<User> searchResults = [];
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 500,
                height: 600,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Pesan Baru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 48), // Balance the close button
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari pengguna...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (text) async {
                        if (text.isNotEmpty) {
                          setState(() {
                            isSearching = true;
                          });
                          
                          try {
                            final users = await _apiService.searchUsers(text);
                            setState(() {
                              searchResults = users;
                              isSearching = false;
                            });
                          } catch (e) {
                            setState(() {
                              isSearching = false;
                            });
                          }
                        } else {
                          setState(() {
                            searchResults.clear();
                            isSearching = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: isSearching
                          ? Center(child: CircularProgressIndicator(color: Colors.blue))
                          : searchResults.isEmpty
                              ? Center(
                                  child: Text(
                                    searchController.text.isEmpty
                                        ? 'Cari pengguna untuk memulai percakapan'
                                        : 'Tidak ada pengguna ditemukan',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final user = searchResults[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: user.profileImage != null
                                            ? NetworkImage('http://localhost:3000/${user.profileImage}')
                                            : AssetImage('images/default_avatar.jpg') as ImageProvider,
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            user.name,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          if (user.isVerified)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4),
                                              child: Icon(Icons.verified, color: Colors.blue, size: 16),
                                            ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        '@${user.username}',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _loadConversation(user);
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
      },
    );
  }

  void _showUserInfo(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400,
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
                        'Info Pengguna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
                SizedBox(height: 20),
                CircleAvatar(
                  backgroundImage: user.profileImage != null
                      ? NetworkImage('http://localhost:3000/${user.profileImage}')
                      : AssetImage('images/default_avatar.jpg') as ImageProvider,
                  radius: 40,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (user.isVerified)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(Icons.verified, color: Colors.blue, size: 20),
                      ),
                  ],
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 16),
                if (user.bio != null && user.bio!.isNotEmpty)
                  Text(
                    user.bio!,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          user.followingCount.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Mengikuti',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          user.followerCount.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Pengikut',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(userId: user.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text('Lihat Profil'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: FutureBuilder<bool>(
                        future: _apiService.isFollowing(user.id),
                        builder: (context, snapshot) {
                          final isFollowing = snapshot.data ?? false;
                          return ElevatedButton(
                            onPressed: () async {
                              await _apiService.followUser(user.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isFollowing ? 'Unfollowed' : 'Following ${user.name}'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing ? Colors.grey[800] : Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(isFollowing ? 'Mengikuti' : 'Ikuti'),
                          );
                        },
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
  }

  void _showMessageSettings() {
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
                leading: Icon(Icons.mark_email_read, color: Colors.white),
                title: Text('Tandai semua sebagai dibaca', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _markAllMessagesAsRead();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_sweep, color: Colors.white),
                title: Text('Hapus semua percakapan', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAllConfirmation();
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text('Pengaturan pesan', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showMessagePreferences();
                },
              ),
              ListTile(
                leading: Icon(Icons.help_outline, color: Colors.white),
                title: Text('Bantuan', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showMessageHelp();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markAllMessagesAsRead() async {
    // Implementation for marking all messages as read
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Semua pesan telah ditandai sebagai dibaca')),
    );
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Hapus Semua Percakapan?', style: TextStyle(color: Colors.white)),
          content: Text(
            'Tindakan ini tidak dapat dibatalkan. Semua percakapan akan dihapus permanen.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Implementation for deleting all conversations
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur hapus semua percakapan akan segera tersedia')),
                );
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

  void _showMessagePreferences() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Pengaturan Pesan', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Terima pesan dari siapa saja', style: TextStyle(color: Colors.white)),
                subtitle: Text('Izinkan pesan dari pengguna yang tidak Anda ikuti', style: TextStyle(color: Colors.grey)),
                value: true,
                onChanged: (value) {
                  // Handle message preference setting
                },
                activeColor: Colors.blue,
              ),
              SwitchListTile(
                title: Text('Notifikasi pesan', style: TextStyle(color: Colors.white)),
                subtitle: Text('Tampilkan notifikasi untuk pesan baru', style: TextStyle(color: Colors.grey)),
                value: true,
                onChanged: (value) {
                  // Handle notification setting
                },
                activeColor: Colors.blue,
              ),
              SwitchListTile(
                title: Text('Konfirmasi baca', style: TextStyle(color: Colors.white)),
                subtitle: Text('Biarkan orang lain tahu ketika Anda membaca pesan mereka', style: TextStyle(color: Colors.grey)),
                value: false,
                onChanged: (value) {
                  // Handle read receipt setting
                },
                activeColor: Colors.blue,
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

  void _showMessageHelp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Bantuan Pesan', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cara menggunakan Direct Messages:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text('• Klik tombol "Tulis Pesan" untuk memulai percakapan baru', style: TextStyle(color: Colors.grey)),
                Text('• Cari pengguna yang ingin Anda kirimi pesan', style: TextStyle(color: Colors.grey)),
                Text('• Ketik pesan Anda dan tekan Enter atau tombol kirim', style: TextStyle(color: Colors.grey)),
                Text('• Klik pada percakapan untuk melanjutkan chat', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 16),
                Text(
                  'Tips:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text('• Gunakan @username untuk menyebut pengguna dalam grup', style: TextStyle(color: Colors.grey)),
                Text('• Pesan yang belum dibaca akan ditandai dengan titik biru', style: TextStyle(color: Colors.grey)),
                Text('• Anda dapat memblokir pengguna melalui profil mereka', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Mengerti', style: TextStyle(color: Colors.blue)),
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
            isActive: true,
            onTap: () {},
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
            onPressed: () => _showNewMessageDialog(),
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
          child: Stack(
            children: [
              Icon(
                icon, 
                color: isActive ? Colors.blue : Colors.grey,
                size: 26,
              ),
              // Show unread message indicator
              if (icon == Icons.mail_outline && _conversations.any((m) => !m.isRead))
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
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
              icon: Stack(
                children: [
                  Icon(Icons.mail_outline, color: Colors.blue, size: 26),
                  if (_conversations.any((m) => !m.isRead))
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
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
}