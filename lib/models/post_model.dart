// lib/models/post_model.dart

class PostModel {
  final int id;
  final String caption;
  final String? imageUrl;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.caption,
    this.imageUrl,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      caption: json['caption'] ?? "",
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
