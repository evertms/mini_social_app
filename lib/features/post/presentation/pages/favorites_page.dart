import 'package:flutter/material.dart';

import '../../data/repositories/mock_post_repository.dart';
import '../../domain/entities/post.dart';
import '../widgets/post_card.dart';
import '../widgets/message_view.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoading = true;
  List<Post> _favoritePosts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final repository = MockRepository();
      final favoritePosts = await repository.getFavorites();

      favoritePosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _favoritePosts = favoritePosts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error al cargar los favoritos';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return MessageView(
        icon: Icons.error_outline,
        message: _errorMessage!,
        actionLabel: 'Reintentar',
        onPressed: _loadFavorites,
      );
    }

    if (_favoritePosts.isEmpty) {
      return MessageView(
        icon: Icons.favorite_border,
        message: 'No tienes posts favoritos aún',
        actionLabel: 'Recargar',
        onPressed: _loadFavorites,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _favoritePosts.length,
        itemBuilder: (context, index) {
          final post = _favoritePosts[index];
          return PostCard(post: post);
        },
      ),
    );
  }
}
