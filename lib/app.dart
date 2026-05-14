import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/app_routes.dart';
import 'core/theme/theme_cubit.dart';
import 'shared/preferences/prefs_service.dart';
import 'features/post/presentation/blocs/favorites_bloc.dart';
import 'features/post/presentation/blocs/favorites_event.dart';
import 'features/post/data/repositories/mock_post_repository.dart';

class App extends StatelessWidget {
  final PrefsService prefsService;

  const App({super.key, required this.prefsService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FavoritesBloc(repository: MockRepository())
            ..add(LoadFavoritesEvent()),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(prefsService),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Mini Social App',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorSchemeSeed: Colors.blue,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorSchemeSeed: Colors.blue,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
