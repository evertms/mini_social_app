import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/entities/post.dart';
import 'create_post_event.dart';
import 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final CreatePostUseCase createPostUseCase;

  CreatePostBloc({required this.createPostUseCase})
    : super(CreatePostInitial()) {
    on<SubmitPostEvent>(_onSubmitPost);
  }

  Future<void> _onSubmitPost(
    SubmitPostEvent event,
    Emitter<CreatePostState> emit,
  ) async {
    emit(CreatePostLoading());

    try {
      final newPost = Post(
        id: 0,
        title: event.title,
        body: event.body,
        userId: 1,
        timestamp: DateTime.now(),
        isFavorite: false,
      );
      await createPostUseCase.execute(newPost);
      emit(CreatePostSuccess());
    } catch (e) {
      emit(CreatePostError(errorMessage: 'Ocurrio un error al crear el post'));
    }
  }
}
