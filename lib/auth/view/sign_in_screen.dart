import 'package:chat_test/auth/service/auth_service.dart';
import 'package:chat_test/chat/view/user_list_screen.dart';
import 'package:flutter/material.dart';

import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signIn() async {
    final error =
        await authService.signIn(emailController.text, passwordController.text);

    if (error == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => UserListScreen()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "이메일")),
            TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "비밀번호"),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: signIn, child: const Text("로그인")),
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen())),
              child: const Text("회원가입하기"),
            ),
          ],
        ),
      ),
    );
  }
}
