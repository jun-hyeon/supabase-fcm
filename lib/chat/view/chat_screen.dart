import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({super.key, required this.receiverId, required this.receiverName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  late final String senderId;

  @override
  void initState() {
    super.initState();
    senderId = supabase.auth.currentUser?.id ?? ''; // 현재 로그인한 유저 ID 가져오기
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;
    await supabase.from('messages').insert({
      'sender_id': senderId,
      'receiver_id': widget.receiverId,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
    });
    _messageController.clear();
  }

  Stream<List<Map<String, dynamic>>> getMessages() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id']) // `id` 기준으로 실시간 감지
        .order('created_at') // 시간순 정렬
        .map((data) => data
            .where((msg) =>
                (msg['sender_id'] == senderId &&
                    msg['receiver_id'] == widget.receiverId) ||
                (msg['sender_id'] == widget.receiverId &&
                    msg['receiver_id'] == senderId))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverName,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, left: 16, right: 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "메시지 입력...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => sendMessage(_messageController.text),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == senderId;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(msg['message']),
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
