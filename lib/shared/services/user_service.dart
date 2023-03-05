import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/collections.dart';
import '../models/roles.dart';
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

  Future<UserModel> getUserFromID(String id) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(Collections.users.toPath)
        .where('id', isEqualTo: id)
        .get();
    assert(snapshot.docs.isNotEmpty,
        'Database Query Error: No user could be found with id $id');
    QueryDocumentSnapshot document = snapshot.docs.first;
    return getUserFromJson(document.data() as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getDataFromID(String id) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(Collections.users.toPath)
        .where('id', isEqualTo: id)
        .get();
    assert(snapshot.docs.isNotEmpty,
        'Database Query Error: No user could be found with id $id');
    return snapshot.docs.first.data() as Map<String, dynamic>;
  }
}
