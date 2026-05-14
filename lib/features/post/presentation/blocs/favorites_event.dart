import '../../domain/entities/post.dart';

abstract class FavoritesEvent {}

class LoadFavoritesEvent extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final Post post;

  ToggleFavoriteEvent(this.post);
}
