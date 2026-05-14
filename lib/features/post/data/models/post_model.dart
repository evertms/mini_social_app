import '../../domain/entities/post.dart';

class PostModel {
  final int id;
  final String title;
  final String body;
  final int userId;
  final DateTime timestamp;
  final bool isFavorite;

  PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.timestamp,
    this.isFavorite = false,
  });

  static PostModel fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
      timestamp: DateTime.now(),
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'body': body, 'userId': userId};
  }

  Post toEntity() {
    return Post(
      id: id,
      title: title,
      body: body,
      userId: userId,
      timestamp: timestamp,
      isFavorite: isFavorite,
    );
  }

  PostModel copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
