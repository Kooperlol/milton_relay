enum Collections { users, events, issues }

extension CollectionsExtension on Collections {
  String get toPath {
    switch (this) {
      case Collections.users:
        return "users";
      case Collections.events:
        return "events";
      case Collections.issues:
        return "issues";
    }
  }
}
