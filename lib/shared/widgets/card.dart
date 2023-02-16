import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/parent/models/parent.dart';
import 'package:milton_relay/shared/utils/color_util.dart';
import 'package:milton_relay/student/models/student.dart';

import '../models/roles.dart';
import '../models/user.dart';
import '../routing/routes.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final TextStyle textStyle = const TextStyle(fontSize: 15);

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.black,
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: user.avatar,
              ),
              const SizedBox(width: 10),
              Text(user.fullName,
                  style: TextStyle(
                      fontSize: 32, fontFamily: 'Lato', color: ColorUtil.blue))
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text("Role: ${user.role.toName}", style: textStyle),
              getUserCard(context)
            ],
          )
        ]),
      ),
    );
  }

  Widget getUserCard(BuildContext context) {
    switch (user.role) {
      case Roles.admin:
        return const SizedBox(width: 0);
      case Roles.instructor:
        return const SizedBox(width: 0);
      case Roles.parent:
        ParentModel parentModel = (user as ParentModel);
        return InkWell(
            onTap: () =>
                context.push(Routes.viewChildren.toPath, extra: parentModel),
            child: Text("View Children",
                style: TextStyle(fontSize: 15, color: ColorUtil.darkRed)));
      case Roles.student:
        StudentModel studentModel = (user as StudentModel);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laude Points: ${studentModel.laudePoints}', style: textStyle),
            Text('Absences: ${studentModel.absences}', style: textStyle)
          ],
        );
    }
  }
}
