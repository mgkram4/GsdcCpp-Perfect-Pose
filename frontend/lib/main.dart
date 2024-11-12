import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/pages/challenges_page.dart';
import 'package:perfect_pose/pages/history_page.dart';
import 'package:perfect_pose/pages/home_page.dart';
import 'package:perfect_pose/pages/login_page.dart';
import 'package:perfect_pose/pages/post_page.dart';
import 'package:perfect_pose/pages/profile_page.dart';
import 'package:perfect_pose/pages/register_page.dart';
import 'package:perfect_pose/pages/stats_page.dart';
import 'package:perfect_pose/services/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // DEFINED ROUTES
  static const String home = "/home";
  static const String login = "/login";
  static const String register = "/register";
  static const String stats = "/stats";
  static const String history = "/history";
  static const String post = "/post";
  static const String challenge = "/challenge";
  static const String profile = "/profile";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        home: (context) => const HomePage(),
        login: (context) => const LoginPage(),
        register: (context) => const RegisterPage(),
        stats: (context) => const StatsPage(),
        history: (context) => const HistoryPage(),
        post: (context) => const PostPage(),
        challenge: (context) => const ChallengesPage(),
        profile: (context) => ProfilePage(),
      },
      home: const AuthWrapper(),
    );
  }
}
