import '../../shared/models/roles.dart';
import '../models/parent.dart';

class ParentService {
  ParentModel getParentFromJson(Map<String, dynamic> json) => ParentModel(
        json['id'] as String,
        json['firstName'] as String,
        json['lastName'] as String,
        json['avatarURL'] as String,
        List<String>.from(json['children'] as List<dynamic>),
      );

  Map<String, dynamic> parentToJson(ParentModel parent) => <String, dynamic>{
        'id': parent.id,
        'firstName': parent.firstName,
        'lastName': parent.lastName,
        'avatarURL': parent.avatarURL,
        'role': Roles.parent.toName,
        'children': parent.children
      };
}
