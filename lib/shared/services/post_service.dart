import 'package:milton_relay/shared/models/post_model.dart';

class PostService {
  PostModel getPostFromJson(String id, Map<String, dynamic> json) => PostModel(
      id,
      json['poster'] as String,
      DateTime.fromMicrosecondsSinceEpoch(json['date'] as int),
      (json['image-urls'] as List<dynamic>).map((e) => e.toString()).toList(),
      json['title'] as String,
      json['description'] as String,
      (json['likes'] as List<dynamic>).map((e) => e.toString()).toList());

  Map<String, dynamic> postToJson(PostModel post) => <String, dynamic>{
        'poster': post.poster,
        'description': post.description,
        'date': post.date.microsecondsSinceEpoch,
        'title': post.title,
        'likes': post.likes,
        'image-urls': post.images
      };
}
