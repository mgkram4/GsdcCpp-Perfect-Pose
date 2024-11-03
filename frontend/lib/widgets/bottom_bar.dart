import 'package:flutter/material.dart';
import 'package:perfect_pose/pages/challenges_page.dart';
import 'package:perfect_pose/pages/history_page.dart';
import 'package:perfect_pose/pages/home_page.dart';
import 'package:perfect_pose/pages/post_page.dart';
import 'package:perfect_pose/pages/stats_page.dart';

class bottom_bar extends StatelessWidget {
  const bottom_bar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_a_photo_outlined),
          label: 'Upload',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
        NavigationDestination(
          icon: Icon(Icons.chrome_reader_mode_outlined),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.badge),
          label: 'Challenges',
        ),
      ],
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PostPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StatsPage()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ChallengesPage()),
            );
            break;
        }
      },
    );
  }
}
