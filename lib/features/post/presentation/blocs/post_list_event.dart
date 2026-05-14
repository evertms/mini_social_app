abstract class PostListEvent {
  const PostListEvent();
}

class FetchPostsRequested extends PostListEvent {
  const FetchPostsRequested();
}
