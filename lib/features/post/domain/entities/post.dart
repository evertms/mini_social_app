class Post {
  final int id;
  final String title;
  final String body;
  final int userId;
  final DateTime timestamp;
  final bool isFavorite;
  
  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.timestamp,
    this.isFavorite = false,
  });
}