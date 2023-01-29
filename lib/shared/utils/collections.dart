enum Collections { users }

extension CollectionsExtension on Collections {
  String get toPath {
    switch (this) {
      case Collections.users:
        return "users";
    }
  }
}
