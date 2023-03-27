enum Collections { users, events, issues, posts, absences }

extension CollectionsExtension on Collections {
  String get toPath {
    switch (this) {
      case Collections.users:
        return "users";
      case Collections.events:
        return "events";
      case Collections.issues:
        return "issues";
      case Collections.posts:
        return "posts";
      case Collections.absences:
        return "absences";
    }
  }
}
