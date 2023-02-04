enum Collections { users, events }

extension CollectionsExtension on Collections {
  String get toPath {
    switch (this) {
      case Collections.users:
        return "users";
      case Collections.events:
        return "events";
    }
  }
}
