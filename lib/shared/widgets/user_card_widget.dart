import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/parent/models/parent_model.dart';
import 'package:milton_relay/shared/utils/color_util.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/student/models/student_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../models/roles.dart';
import '../models/user_model.dart';
import '../routing/routes.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final Widget? icon;
  final TextStyle textStyle = TextStyle(fontSize: 3.w);

  UserCard(this.user, {Key? key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorUtil.snowWhite,
      shadowColor: Colors.black,
      elevation: 2,
      margin: EdgeInsets.all(1.w),
      child: Padding(
          padding: EdgeInsets.all(0.5.w),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              radius: 7.w,
              backgroundColor: ColorUtil.red,
              backgroundImage: user.avatar.image,
            ),
            SizedBox.square(dimension: 2.w),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName,
                        style: TextStyle(
                            fontSize: 4.w,
                            fontFamily: 'Lato',
                            color: ColorUtil.blue)),
                    SizedBox(height: 0.5.w),
                    Text("Role: ${user.role.toName.capitalize()}",
                        style: textStyle),
                    getUserCard(context)
                  ],
                ),
              ],
            ),
            if (icon != null) const Spacer(),
            if (icon != null) icon!
          ])),
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
            Text('Laude Points: ${studentModel.laudePoints.toStringAsFixed(2)}',
                style: textStyle),
            Text('Absences: ${studentModel.absences.length}', style: textStyle)
          ],
        );
    }
  }
}
