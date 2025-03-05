class ChatUser {
  final String email;
  final String name;
  final String id;

  ChatUser({
    required this.id,
    required this.email,
    required this.name,
  });

  factory ChatUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson(ChatUser user) {
    return {
      'id': user.id,
      'email': user.email,
      'name': user.name,
    };
  }
}
