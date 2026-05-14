import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/mock_post_repository.dart';
import '../blocs/post_list_state.dart';
import '../blocs/post_list_event.dart';
import '../blocs/post_list_bloc.dart';
import '../widgets/message_view.dart';
import '../widgets/post_card.dart';

class PostListPage extends StatelessWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PostListBloc(repository: MockRepository())
            ..add(const FetchPostsRequested()),
      child: const _PostListView(),
    );
  }
}

class _PostListView extends StatelessWidget {
  const _PostListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Social App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              context.push('/favorites');
            },
          ),
        ],
      ),
      body: BlocBuilder<PostListBloc, PostListState>(
        builder: (context, state) {
          if (state is PostListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PostListError) {
            return MessageView(
              icon: Icons.error_outline,
              message: state.errorMessage,
              actionLabel: 'Reintentar',
              onPressed: () {
                context.read<PostListBloc>().add(const FetchPostsRequested());
              },
            );
          }

          if (state is PostListEmpty) {
            return MessageView(
              icon: Icons.inbox_outlined,
              message: 'No hay posts para mostrar',
              actionLabel: 'Recargar',
              onPressed: () {
                context.read<PostListBloc>().add(const FetchPostsRequested());
              },
            );
          }

          if (state is PostListLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostListBloc>().add(const FetchPostsRequested());
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
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
