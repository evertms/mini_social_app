import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_local_datasource.dart';
import '../datasources/post_remote_datasource.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remoteDataSource;
  final PostLocalDataSource _localDataSource;

  PostRepositoryImpl({
    required PostRemoteDataSource remoteDataSource,
    required PostLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<List<Post>> getPosts() async {
    try {
      final localPosts = await _localDataSource.getAllPosts();
      final favoritesById = {
        for (final post in localPosts) post.id: post.isFavorite,
      };

      final remotePosts = await _remoteDataSource.fetchPosts();
      final mergedPosts = remotePosts
          .map(
            (post) =>
                post.copyWith(isFavorite: favoritesById[post.id] ?? false),
          )
          .toList();

      for (final post in mergedPosts) {
        await _localDataSource.insertPost(post);
      }

      return mergedPosts.map((post) => post.toEntity()).toList(growable: false);
    } catch (_) {
      final localPosts = await _localDataSource.getAllPosts();
      return localPosts.map((post) => post.toEntity()).toList(growable: false);
    }
  }

  @override
  Future<Post> createPost(Post post) async {
    final createdModel = await _remoteDataSource.createPost(
      PostModel(
        id: post.id,
        title: post.title,
        body: post.body,
        userId: post.userId,
        timestamp: post.timestamp,
        isFavorite: post.isFavorite,
      ),
    );

    await _localDataSource.insertPost(createdModel);
    return createdModel.toEntity();
  }

  @override
  Future<List<Post>> getFavorites() async {
    final localPosts = await _localDataSource.getAllPosts();
    return localPosts
        .where((post) => post.isFavorite)
        .map((post) => post.toEntity())
        .toList(growable: false);
  }

  @override
  Future<void> toggleFavorite(Post post) async {
    await _localDataSource.updateFavorite(post.id, !post.isFavorite);
  }
}
