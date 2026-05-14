import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/post_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final PostRepository repository;

  FavoritesBloc({required this.repository}) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
      LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getFavorites();
      favorites.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError("No se pudieron cargar los favoritos"));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event, Emitter<FavoritesState> emit) async {
    try {
      await repository.toggleFavorite(event.post);
      final favorites = await repository.getFavorites();
      favorites.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError("Error al actualizar favorito"));
    }
  }
}
