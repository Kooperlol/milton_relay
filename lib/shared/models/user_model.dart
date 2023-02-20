import 'package:flutter/widgets.dart';
import 'package:milton_relay/shared/utils/roles.dart';

class UserModel {
  final String id, firstName, lastName, avatarURL;
  final Roles role;
  late final Image avatar;

  UserModel(this.id, this.firstName, this.lastName, this.avatarURL, this.role) {
    avatar = initAvatar();
  }

  String get fullName => '$firstName $lastName';

  Image initAvatar() {
    return Image.network(avatarURL);
  }
}
