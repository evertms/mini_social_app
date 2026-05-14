abstract class CreatePostEvent {}

class SubmitPostEvent extends CreatePostEvent {
  final String title;
  final String body;

  SubmitPostEvent({required this.title, required this.body});
}
