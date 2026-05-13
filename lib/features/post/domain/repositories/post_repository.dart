import '../entities/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts();
  Future<Post> createPost(Post post);
  Future<List<Post>> getFavorites();
  Future<void> toggleFavorite(Post post);
}
