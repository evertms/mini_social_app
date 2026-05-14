import 'package:mini_social_app/features/post/domain/entities/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/preferences/prefs_service.dart';

import '../../domain/repositories/post_repository.dart';

class MockRepository implements PostRepository {
  final bool shouldFail;
  final bool shouldReturnEmpty;

  MockRepository({this.shouldFail = false, this.shouldReturnEmpty = false});

  @override
  Future<Post> createPost(Post post) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return post;
  }

  @override
  Future<List<Post>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsService = PrefsService(prefs);
    final favIds = prefsService.getFavIds();

    final posts = await getPosts();
    return posts.where((post) => favIds.contains(post.id)).toList();
  }

  @override
  Future<List<Post>> getPosts() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (shouldFail) {
      throw Exception("No se pudieron cargar los posts");
    }

    if (shouldReturnEmpty) {
      return [];
    }

    final now = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    final prefsService = PrefsService(prefs);
    final favIds = prefsService.getFavIds();

    final posts = [
      Post(
        id: 1,
        title: "Primer post de la tarea",
        body:
            "Este es el body de post que acabo de crear donde usamos un mock repository hasta que henrry haga su parte.",
        userId: 1,
        timestamp: now,
        isFavorite: favIds.contains(1),
      ),
      Post(
        id: 2,
        title: "Aprendiendo BLoC",
        body:
            "Este es el body de post que acabo de crear donde usamos un mock repository hasta que henrry haga su parte.",
        userId: 1,
        timestamp: now,
        isFavorite: favIds.contains(2),
      ),
      Post(
        id: 3,
        title: "Mejores practicas en Flutter",
        body:
            "Este es el body de post que acabo de crear donde usamos un mock repository hasta que henrry haga su parte.",
        userId: 1,
        timestamp: now,
        isFavorite: favIds.contains(3),
      ),
    ];

    posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return posts;
  }

  @override
  Future<void> toggleFavorite(Post post) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final prefs = await SharedPreferences.getInstance();
    final prefsService = PrefsService(prefs);
    await prefsService.toggleFavId(post.id);
  }
}
