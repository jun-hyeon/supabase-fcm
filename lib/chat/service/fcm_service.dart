import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient supabase = Supabase.instance.client;

  /// 🔹 FCM 초기화 (푸시 알림 설정)
  Future<void> initializeFCM() async {
    // 알림 권한 요청 (iOS)

    supabase.auth.onAuthStateChange.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn) {
        await _firebaseMessaging.requestPermission();
        final fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          _saveFcmToken(fcmToken);
        }
      }
    });

    _firebaseMessaging.onTokenRefresh.listen((fcmToken) async {
      await _saveFcmToken(fcmToken);
    });

    // Foreground 메시지 수신 설정
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message.notification?.title ?? '알림',
          message.notification?.body ?? '새로운 메시지가 도착했습니다.');
    });

    // 앱이 종료된 상태에서 푸시 알림 클릭 시
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 앱이 푸시 알림을 통해 열렸습니다: ${message.notification?.title}");
    });

    // 로컬 알림 초기화
    _initLocalNotifications();
  }

  /// 🔹 현재 로그인한 유저의 FCM 토큰을 Supabase에 저장
  Future<void> _saveFcmToken(String fcmToken) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase.from('users').update({
        'fcm_token': fcmToken,
      }).eq('id', user.id);
    }
  }

  /// 🔹 로컬 알림 초기화
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(settings);
  }

  /// 🔹 로컬 알림 표시
  void _showNotification(String title, String body) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    _localNotifications.show(0, title, body, notificationDetails);
  }
}
