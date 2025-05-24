 import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
          const SizedBox(height: 12),
          const Text("Royandi Randi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("@RandiRoyan92443", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.cake, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text("Born February 6, 2004", style: TextStyle(color: Colors.grey)),
            ],
          ),
          Row(
            children: const [
              Icon(Icons.calendar_month, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text("Joined December 2024", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          const Text("13 Following   0 Followers", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
