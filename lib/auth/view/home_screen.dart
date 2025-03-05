import 'package:chat_test/auth/service/auth_service.dart';
import 'package:flutter/material.dart';

import 'sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();

  void signOut(BuildContext context) async {
    await authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("홈 화면"),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout), onPressed: () => signOut(context))
        ],
      ),
      body: const Center(child: Text("환영합니다!")),
    );
  }
}
