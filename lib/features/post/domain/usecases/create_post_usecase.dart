import '../entities/post.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<Post> execute(Post post) async {
    return await repository.createPost(post);
  }
}
