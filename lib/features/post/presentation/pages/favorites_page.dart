import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/favorites_bloc.dart';
import '../blocs/favorites_state.dart';
import '../blocs/favorites_event.dart';
import '../widgets/post_card.dart';
import '../widgets/message_view.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoritesError) {
            return MessageView(
              icon: Icons.error_outline,
              message: state.message,
              actionLabel: 'Reintentar',
              onPressed: () {
                context.read<FavoritesBloc>().add(LoadFavoritesEvent());
              },
            );
          }

          if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return MessageView(
                icon: Icons.favorite_border,
                message: 'No tienes posts favoritos aún',
                actionLabel: 'Recargar',
                onPressed: () {
                  context.read<FavoritesBloc>().add(LoadFavoritesEvent());
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FavoritesBloc>().add(LoadFavoritesEvent());
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final post = state.favorites[index];
                  return PostCard(post: post);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
