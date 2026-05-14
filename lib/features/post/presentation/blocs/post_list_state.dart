import '../../domain/entities/post.dart';

abstract class PostListState {
  const PostListState();
}

class PostListInitial extends PostListState {
  const PostListInitial();
}

class PostListLoading extends PostListState {
  const PostListLoading();
}

class PostListLoaded extends PostListState {
  final List<Post> posts;

  const PostListLoaded({required this.posts});
}

class PostListError extends PostListState {
  final String errorMessage;

  const PostListError({required this.errorMessage});
}

class PostListEmpty extends PostListState {
  const PostListEmpty();
}
