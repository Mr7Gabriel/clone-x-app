import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String name;
  final String username;
  final String content;
  final String imageUrl;

  const PostCard({
    super.key,
    required this.name,
    required this.username,
    required this.content,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Text(username, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.comment, color: Colors.grey, size: 18),
              SizedBox(width: 8),
              Icon(Icons.repeat, color: Colors.grey, size: 18),
              SizedBox(width: 8),
              Icon(Icons.favorite, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Icon(Icons.bookmark, color: Colors.grey, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
