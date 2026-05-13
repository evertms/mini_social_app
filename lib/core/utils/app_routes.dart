import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Este archivo centraliza la navegación de la app siguiendo SRP.
// Se ubica en lib/core/utils/ o lib/app_routes.dart (según escala).

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'post_list',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Post List Page (Placeholder)')),
      ),
    ),
    // Ejemplo de cómo se añadirían el resto:
    // GoRoute(
    //   path: '/create-post',
    //   name: 'create_post',
    //   builder: (context, state) => const CreatePostPage(),
    // ),
    // GoRoute(
    //   path: '/favorites',
    //   name: 'favorites',
    //   builder: (context, state) => const FavoritesPage(),
    // ),
  ],
);
