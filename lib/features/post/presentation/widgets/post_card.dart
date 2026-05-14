import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';
import '../../utils/format_timestamp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/favorites_bloc.dart';
import '../blocs/favorites_event.dart';
import '../blocs/favorites_state.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final favState = context.watch<FavoritesBloc>().state;
    bool isFavorite = post.isFavorite;

    if (favState is FavoritesLoaded) {
      isFavorite = favState.favorites.any((f) => f.id == post.id);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<FavoritesBloc>().add(
                      ToggleFavoriteEvent(post),
                    );
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.body, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text('Usuario ${post.userId}'),
                const Spacer(),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(formatTimestamp(post.timestamp)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
