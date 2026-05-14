import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/app_routes.dart';
import 'features/post/presentation/blocs/favorites_bloc.dart';
import 'features/post/presentation/blocs/favorites_event.dart';
import 'features/post/data/repositories/mock_post_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FavoritesBloc(repository: MockRepository())
            ..add(LoadFavoritesEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Mini Social App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        routerConfig: router,
      ),
    );
  }
}
