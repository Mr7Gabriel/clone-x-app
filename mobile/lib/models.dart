class User {
  final int id;
  final String username;
  final String email;
  final String name;
  final String? bio;
  final String? location;
  final String? website;
  final String? profileImage;
  final String? bannerImage;
  final bool isVerified;
  final int followerCount;
  final int followingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    this.bio,
    this.location,
    this.website,
    this.profileImage,
    this.bannerImage,
    required this.isVerified,
    required this.followerCount,
    required this.followingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      name: map['name'],
      bio: map['bio'],
      location: map['location'],
      website: map['website'],
      profileImage: map['profile_image'],
      bannerImage: map['banner_image'],
      isVerified: map['is_verified'] == 1,
      followerCount: map['follower_count'] ?? 0,
      followingCount: map['following_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at'].toString()),
      updatedAt: DateTime.parse(map['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'bio': bio,
      'location': location,
      'website': website,
      'profile_image': profileImage,
      'banner_image': bannerImage,
      'is_verified': isVerified ? 1 : 0,
      'follower_count': followerCount,
      'following_count': followingCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Post {
  final int id;
  final int userId;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final int retweetCount;
  final int replyCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // User info (from join)
  final String? username;
  final String? name;
  final String? profileImage;
  final bool? isVerified;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.likeCount,
    required this.retweetCount,
    required this.replyCount,
    required this.createdAt,
    required this.updatedAt,
    this.username,
    this.name,
    this.profileImage,
    this.isVerified,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['user_id'],
      content: map['content'],
      imageUrl: map['image_url'],
      likeCount: map['like_count'] ?? 0,
      retweetCount: map['retweet_count'] ?? 0,
      replyCount: map['reply_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at'].toString()),
      updatedAt: DateTime.parse(map['updated_at'].toString()),
      username: map['username'],
      name: map['name'],
      profileImage: map['profile_image'],
      isVerified: map['is_verified'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'like_count': likeCount,
      'retweet_count': retweetCount,
      'reply_count': replyCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Like {
  final int id;
  final int userId;
  final int postId;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      id: map['id'],
      userId: map['user_id'],
      postId: map['post_id'],
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Follow {
  final int id;
  final int followerId;
  final int followingId;
  final DateTime createdAt;

  Follow({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory Follow.fromMap(Map<String, dynamic> map) {
    return Follow(
      id: map['id'],
      followerId: map['follower_id'],
      followingId: map['following_id'],
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class XNotification {
  final int id;
  final int userId;
  final String type;
  final int actorId;
  final int? postId;
  final String? content;
  final bool isRead;
  final DateTime createdAt;
  
  // Actor info (from join)
  final String? actorUsername;
  final String? actorName;
  final String? actorProfileImage;
  final bool? actorIsVerified;

  XNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.actorId,
    this.postId,
    this.content,
    required this.isRead,
    required this.createdAt,
    this.actorUsername,
    this.actorName,
    this.actorProfileImage,
    this.actorIsVerified,
  });

  factory XNotification.fromMap(Map<String, dynamic> map) {
    return XNotification(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      actorId: map['actor_id'],
      postId: map['post_id'],
      content: map['content'],
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at'].toString()),
      actorUsername: map['actor_username'],
      actorName: map['actor_name'],
      actorProfileImage: map['actor_profile_image'],
      actorIsVerified: map['actor_is_verified'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'actor_id': actorId,
      'post_id': postId,
      'content': content,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  
  // Sender info (from join)
  final String? senderUsername;
  final String? senderName;
  final String? senderProfileImage;
  final bool? senderIsVerified;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.senderUsername,
    this.senderName,
    this.senderProfileImage,
    this.senderIsVerified,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      content: map['content'],
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at'].toString()),
      senderUsername: map['sender_username'],
      senderName: map['sender_name'],
      senderProfileImage: map['sender_profile_image'],
      senderIsVerified: map['sender_is_verified'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Reply {
  final int id;
  final int userId;
  final int postId;
  final String content;
  final DateTime createdAt;
  
  // User info (from join)
  final String? username;
  final String? name;
  final String? profileImage;
  final bool? isVerified;

  Reply({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    this.username,
    this.name,
    this.profileImage,
    this.isVerified,
  });

  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      id: map['id'],
      userId: map['user_id'],
      postId: map['post_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at'].toString()),
      username: map['username'],
      name: map['name'],
      profileImage: map['profile_image'],
      isVerified: map['is_verified'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Bookmark {
  final int id;
  final int userId;
  final int postId;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'],
      userId: map['user_id'],
      postId: map['post_id'],
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}