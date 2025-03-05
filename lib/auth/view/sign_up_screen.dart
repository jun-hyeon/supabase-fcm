import 'package:chat_test/auth/service/auth_service.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void signUp() async {
    final error = await authService.signUp(
      emailController.text,
      passwordController.text,
      nameController.text,
    );

    if (error == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("회원가입 성공!")));
      Navigator.pop(context); // 로그인 화면으로 이동
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "이름")),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "이메일")),
            TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "비밀번호"),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: signUp, child: const Text("회원가입")),
          ],
        ),
      ),
    );
  }
}
