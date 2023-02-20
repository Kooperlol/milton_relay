import '../utils/roles.dart';
import '../models/user_model.dart';

class UserService {
  UserModel getUserFromJson(Map<String, dynamic> json) => UserModel(
      json['id'] as String,
      json['firstName'] as String,
      json['lastName'] as String,
      json['avatarURL'] as String,
      roleFromString(json['role'] as String));

  Map<String, dynamic> userToJson(UserModel user) => <String, dynamic>{
        'id': user.id,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'avatarURL': user.avatarURL,
        'role': user.role.toName,
      };
}
