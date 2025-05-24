import 'package:flutter/material.dart';
import '../ widgets/post_card.dart';
import '../ widgets/side_nav.dart';
import '../widgets/post_card.dart'; // Impor PostCard
import '../widgets/side_nav.dart';  // Impor SideNav
import 'profile_page.dart'; // Impor ProfilePage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isDesktop
          ? null
          : AppBar(
        backgroundColor: Colors.black,
        title: const Icon(Icons.home, size: 32),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // Tambahkan aksi pencarian
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {}, // Tambahkan aksi notifikasi
          ),
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () {}, // Tambahkan aksi pesan
          )
        ],
      ),
      body: Row(
        children: [
          if (isDesktop) const SideNav(),
          Expanded(
            flex: 5,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: const [
                    Text("For you", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 20),
                    Text("Following", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                const PostCard(
                  name: "Kegoblogan.Unfaedah",
                  content: "KRITIK KDM TTG SISWA DIKIRIM KE BARAK MILITER.",
                  imageUrl: "https://i.imgur.com/svK0YwE.jpeg",
                  username: "@kegoblogan",
                ),
                const PostCard(
                  name: "Biku Live",
                  content: "Charming but missing your company 🥰",
                  imageUrl: "https://i.imgur.com/WvJ9WQk.jpeg",
                  username: "@DemeoMalli65159",
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: ""),
        ],
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton(
        onPressed: () {}, // Tombol aksi tambahan
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
