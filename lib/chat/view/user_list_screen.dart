import 'package:chat_test/chat/model/chat_user.dart';
import 'package:chat_test/chat/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/service/auth_service.dart';
import '../../auth/view/sign_in_screen.dart';

class UserListScreen extends StatefulWidget {
  UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final AuthService authService = AuthService();

  ChatUser? currentUser;
  List<ChatUser> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  /// ✅ 현재 로그인한 유저 & 전체 유저 리스트 가져오기
  Future<void> fetchUsers() async {
    // ✅ 현재 로그인한 유저 가져오기
    final loggedInUser = await authService.getCurrentUser();

    // ✅ 모든 유저 가져오기
    final allUsers = await supabase.from('users').select('id, email, name');

    // ✅ `ChatUser` 리스트 변환
    List<ChatUser> userList =
        allUsers.map((user) => ChatUser.fromJson(user)).toList();

    // ✅ 현재 로그인한 유저를 리스트에서 제외
    userList.removeWhere((user) => user.id == loggedInUser?.id);

    setState(() {
      currentUser = loggedInUser;
      users = userList;
    });
  }

  /// 로그아웃
  void signOut(BuildContext context) async {
    await authService.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('유저 리스트'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout), onPressed: () => signOut(context))
        ],
      ),
      body: users.isEmpty && currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ 현재 로그인한 유저 표시 (리스트에서 제외됨)
                if (currentUser != null)
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const Icon(Icons.account_circle, size: 40),
                      title: Text(currentUser!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(currentUser!.email),
                      tileColor: Colors.blue.shade100,
                    ),
                  ),

                // ✅ 다른 유저 리스트
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverId: user.id,
                                receiverName: user.name,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
