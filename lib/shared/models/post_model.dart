class PostModel {
  final DateTime date;
  final List<String> images, likes;
  final String id, poster;
  String title, description;

  PostModel(this.id, this.poster, this.date, this.images, this.title,
      this.description, this.likes);
}
