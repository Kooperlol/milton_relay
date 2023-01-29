import 'package:json_annotation/json_annotation.dart';

import '../../shared/models/roles.dart';
import '../../shared/models/user.dart';

@JsonSerializable(explicitToJson: true)
class ParentModel extends UserModel {
  final List<String> children;

  ParentModel(String id, String firstName, String lastName, String avatarURL,
      this.children)
      : super(id, firstName, lastName, avatarURL, Roles.parent);
}
