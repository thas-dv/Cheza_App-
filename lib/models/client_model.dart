// lib/models/client_model.dart

class ClientModel {
  final String userId;
  final int attendanceId;
  final String username;
  final String? avatarUrl;
  final int postCount;
  final int inviteCount;

  ClientModel({
    required this.userId,
    required this.attendanceId,
    required this.username,
    required this.avatarUrl,
    required this.postCount,
    required this.inviteCount,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      userId: json['user_id'],
      attendanceId: json['id'],
      username: json['profiles']['username'],
      avatarUrl: json['profiles']['avatar_url'],
      postCount: json['post_count'] ?? 0,
      inviteCount: json['invite_count'] ?? 0,
    );
  }
}
