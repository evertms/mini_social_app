import 'package:mini_social_app/features/post/domain/entities/post.dart';

import '../../domain/repositories/post_repository.dart';

class MockRepository implements PostRepository {
  @override
  Future<Post> createPost(Post post) {
    // TODO: implement createPost
    throw UnimplementedError();
  }

  @override
  Future<List<Post>> getFavorites() {
    // TODO: implement getFavorites
    throw UnimplementedError();
  }

  @override
  Future<List<Post>> getPosts() {
    // TODO: implement getPosts
    throw UnimplementedError();
  }

  @override
  Future<void> toggleFavorite(Post post) {
    // TODO: implement toggleFavorite
    throw UnimplementedError();
  }
  
}