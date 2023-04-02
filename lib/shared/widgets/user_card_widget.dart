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
  // Stores the user to display.
  final UserModel user;
  // If specified, this will stores an icon to display on the card.
  final Widget? icon;
  // The text style that'll be used commonly on the card.
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
            // Avatar of the user.
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
                    // Displays the user's full name.
                    Text(user.fullName,
                        style: TextStyle(fontSize: 4.w, color: ColorUtil.blue)),
                    SizedBox(height: 0.5.w),
                    // Displays the user's role.
                    Text("Role: ${user.role.toName.capitalize()}",
                        style: textStyle),
                    // Gets content that is custom to the user's role.
                    getUserCard(context)
                  ],
                ),
              ],
            ),
            // Display the [icon] if it is specified.
            if (icon != null) const Spacer(),
            if (icon != null) icon!
          ])),
    );
  }

  /// Returns a column of extra information relating to the user's role.
  Widget getUserCard(BuildContext context) {
    switch (user.role) {
      // No extra content for Admins or Instructors.
      case Roles.admin:
        return const SizedBox(width: 0);
      case Roles.instructor:
        return const SizedBox(width: 0);
      // Parents will have a button, which allows users to view their children in a new screen.
      case Roles.parent:
        ParentModel parentModel = (user as ParentModel);
        return InkWell(
            onTap: () =>
                context.push(Routes.viewChildren.toPath, extra: parentModel),
            child: Text("View Children",
                style: TextStyle(fontSize: 3.w, color: ColorUtil.darkRed)));
      // Students have a display for Laude Points and their absence count.
      case Roles.student:
        StudentModel studentModel = (user as StudentModel);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Laude Points: ${studentModel.laudePoints == 0 ? 'N/A' : studentModel.laudePoints.toStringAsFixed(2)}',
                style: textStyle),
            Text('Absences: ${studentModel.absences.length}', style: textStyle)
          ],
        );
    }
  }
}
