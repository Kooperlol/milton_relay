import '../../shared/models/roles.dart';
import '../../shared/models/user.dart';

class ParentModel extends UserModel {
  final List<String> children;

  ParentModel(String id, String firstName, String lastName, String avatarURL,
      this.children)
      : super(id, firstName, lastName, avatarURL, Roles.parent);
}
