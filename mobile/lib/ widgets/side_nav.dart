import 'package:flutter/material.dart';
import '../pages/profile_page.dart'; // Impor ProfilePage

class SideNav extends StatelessWidget {
  const SideNav({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: Colors.black,
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home), label: Text("")),
        NavigationRailDestination(icon: Icon(Icons.search), label: Text("")),
        NavigationRailDestination(icon: Icon(Icons.notifications), label: Text("")),
        NavigationRailDestination(icon: Icon(Icons.mail), label: Text("")),
        NavigationRailDestination(icon: Icon(Icons.group), label: Text("")),
        NavigationRailDestination(icon: Icon(Icons.person), label: Text("")),
      ],
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 5) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        }
      },
      labelType: NavigationRailLabelType.none,
    );
  }
}
