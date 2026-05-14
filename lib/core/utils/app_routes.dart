import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_social_app/features/post/domain/usecases/create_post_usecase.dart';
import 'package:mini_social_app/features/post/presentation/blocs/create_post_bloc.dart';
import '../../features/post/presentation/pages/post_list_page.dart';
import '../../features/post/presentation/pages/create_post_page.dart';
import '../../features/post/data/repositories/mock_post_repository.dart';
import '../../features/post/presentation/pages/favorites_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'post_list',
      builder: (context, state) => const PostListPage(),
    ),
    GoRoute(
      path: '/create-post',
      name: 'create_post',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => CreatePostBloc(
            createPostUseCase: CreatePostUseCase(MockRepository()),
          ),
          child: CreatePostPage(),
        );
      },
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
  ],
);
