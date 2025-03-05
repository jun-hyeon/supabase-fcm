import 'package:chat_test/auth/service/auth_service.dart';
import 'package:chat_test/auth/view/sign_in_screen.dart';
import 'package:chat_test/chat/view/user_list_screen.dart';
import 'package:chat_test/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat/service/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://ezuycrmyfdfgjinbzznh.supabase.co',
    anonKey: '${dotenv.env['SUPABASE_API_KEY']}',
  );
  print('Supabase initialized');
  await FCMService().initializeFCM();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return MaterialApp(
      home: authService.currentUser != null
          ? UserListScreen()
          : const SignInScreen(),
    );
  }
}
