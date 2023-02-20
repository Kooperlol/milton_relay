import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/parent/models/parent.dart';
import 'package:milton_relay/shared/utils/color_util.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/student/models/student.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../utils/roles.dart';
import '../models/user_model.dart';
import '../routing/routes.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final TextStyle textStyle = TextStyle(fontSize: 3.w);

  UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(255, 250, 250, 1),
      shadowColor: Colors.black,
      elevation: 2,
      margin: EdgeInsets.all(1.w),
      child: Padding(
        padding: EdgeInsets.all(0.5.w),
        child: Row(children: [
          CircleAvatar(
            radius: 7.w,
            backgroundColor: ColorUtil.red,
            backgroundImage: user.avatar.image,
          ),
          SizedBox.square(dimension: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName,
                  style: TextStyle(
                      fontSize: 4.w,
                      fontFamily: 'Lato',
                      color: ColorUtil.blue)),
              SizedBox(height: 0.5.w),
              Text("Role: ${user.role.toName.capitalize()}", style: textStyle),
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
                style: TextStyle(fontSize: 3.w, color: ColorUtil.darkRed)));
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
