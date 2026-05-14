import 'package:drift/drift.dart';

import '../../../../shared/database/app_database.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {
  Future<List<PostModel>> getAllPosts();
  Future<void> insertPost(PostModel post);
  Future<void> updateFavorite(int postId, bool isFavorite);
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final AppDatabase _db;

  PostLocalDataSourceImpl({required AppDatabase database}) : _db = database;

  @override
  Future<List<PostModel>> getAllPosts() async {
    final rows = await (_db.select(
      _db.posts,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)])).get();

    return rows
        .map(
          (row) => PostModel(
            id: row.id,
            title: row.title,
            body: row.body,
            userId: row.userId,
            timestamp: row.timestamp,
            isFavorite: row.isFavorite,
          ),
        )
        .toList();
  }

  @override
  Future<void> insertPost(PostModel post) async {
    await _db
        .into(_db.posts)
        .insertOnConflictUpdate(
          PostsCompanion.insert(
            id: Value(post.id),
            title: post.title,
            body: post.body,
            userId: post.userId,
            timestamp: post.timestamp,
            isFavorite: Value(post.isFavorite),
          ),
        );
  }

  @override
  Future<void> updateFavorite(int postId, bool isFavorite) async {
    await (_db.update(_db.posts)..where((tbl) => tbl.id.equals(postId))).write(
      PostsCompanion(isFavorite: Value(isFavorite)),
    );
  }
}
