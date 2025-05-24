// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'profile_page.dart';
// import 'post_card.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   final String profileImage = 'https://randomuser.me/api/portraits/men/32.jpg';
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isMobile = MediaQuery.of(context).size.width < 600;
//
//     // ⬇️ Pindahkan icons ke dalam build agar bisa digunakan di widget
//     final List<Map<String, dynamic>> icons = [
//       {
//         'url': 'https://www.svgrepo.com/show/508473/home-1.svg',
//         'label': 'Home',
//       },
//       {
//         'url': 'https://www.svgrepo.com/show/532602/compass.svg',
//         'label': 'Grok',
//       },
//       {
//         'url': 'https://www.svgrepo.com/show/506752/notification.svg',
//         'label': 'Notifications',
//       },
//       {
//         'url': 'https://www.svgrepo.com/show/499790/message.svg',
//         'label': 'Messages',
//       },
//     ];
//
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           leading: GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ProfilePage()),
//               );
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: CircleAvatar(
//                 backgroundImage: NetworkImage(profileImage),
//               ),
//             ),
//           ),
//           title: SvgPicture.network(
//             'https://upload.wikimedia.org/wikipedia/commons/5/5f/X_logo_2023_original.svg',
//             width: 30,
//             color: Colors.white,
//           ),
//           centerTitle: true,
//           actions: const [
//             Padding(
//               padding: EdgeInsets.only(right: 16),
//               child: Icon(Icons.more_vert),
//             )
//           ],
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: "For you"),
//               Tab(text: "Following"),
//             ],
//           ),
//         ),
//         body: const TabBarView(
//           children: [
//             PostCard(),
//             Center(child: Text("Belum ada postingan di 'Following'")),
//           ],
//         ),
//         bottomNavigationBar: isMobile
//             ? BottomNavigationBar(
//           backgroundColor: Colors.black,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.grey,
//           type: BottomNavigationBarType.fixed,
//           items: [
//             for (var icon in icons)
//               BottomNavigationBarItem(
//                 icon: SvgPicture.network(
//                   icon['url'],
//                   width: 24,
//                   color: Colors.white,
//                 ),
//                 label: '',
//               ),
//           ],
//         )
//             : null,
//         floatingActionButton: isMobile
//             ? FloatingActionButton(
//           backgroundColor: Colors.blue,
//           onPressed: () {},
//           child: const Icon(Icons.add),
//         )
//             : null,
//       ),
//     );
//   }
// }
