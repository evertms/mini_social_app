import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/post_repository.dart';
import 'post_list_state.dart';
import 'post_list_event.dart';

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final PostRepository repository;

  PostListBloc({required this.repository}) : super(const PostListInitial()) {
    on<FetchPostsRequested>(_onFetchPostsRequested);
  }

  Future<void> _onFetchPostsRequested(
    FetchPostsRequested event,
    Emitter<PostListState> emit,
  ) async {
    emit(const PostListLoading());

    try {
      final posts = await repository.getPosts();

      if(posts.isEmpty) {
        emit(const PostListEmpty());
        return;
      }

      emit(PostListLoaded(posts: posts));
    }
    catch(_) {
      emit(const PostListError(errorMessage: "Hubo un error al cargar los posts"));
    }


  }
}
