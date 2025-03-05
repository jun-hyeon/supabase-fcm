import 'package:chat_test/chat/model/chat_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // 🔹 회원가입
  Future<String?> signUp(String email, String password, String name) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        final String? fcmToken = await _firebaseMessaging.getToken();
        // 🔥 회원가입 성공 시 `users` 테이블에 저장
        await supabase.from('users').insert({
          'id': user.id, // auth.users 테이블과 동일한 ID 사용
          'email': email,
          'name': name,
          'fcm_token': fcmToken,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      return null; // 성공 시 에러 없음
    } catch (e) {
      return e.toString(); // 에러 반환
    }
  }

  // 🔹 로그인
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth
          .signInWithPassword(email: email, password: password);
      if (response.user != null) {
        _saveFcmToken(response.user!.id);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// 🔹 FCM 토큰을 Supabase `users` 테이블에 저장
  Future<void> _saveFcmToken(String userId) async {
    final String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await supabase
          .from('users')
          .update({'fcm_token': token}).match({'id': userId});
    }
  }

  // 🔹 로그아웃
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // 🔹 현재 로그인된 유저 정보 가져오기
  User? get currentUser => supabase.auth.currentUser;

  Future<ChatUser?> getCurrentUser() async {
    // 🔹 Supabase에서 현재 로그인된 유저 정보 가져오기
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      print("❌ 현재 로그인된 유저가 없습니다.");
      return null;
    }

    // 🔹 `users` 테이블에서 현재 유저의 추가 정보(email, name) 가져오기
    final response = await supabase
        .from('users')
        .select('id, email, name')
        .eq('id', currentUser.id)
        .maybeSingle(); // 한 개의 결과만 가져옴

    if (response == null) {
      print("❌ 유저 정보를 찾을 수 없습니다.");
      return null;
    }

    // 🔹 `ChatUser` 객체로 변환하여 반환
    return ChatUser.fromJson(response);
  }
}
