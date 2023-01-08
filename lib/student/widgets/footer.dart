import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:milton_relay/shared/routing/router_routes.dart';

import '../../shared/utils/color_util.dart';

GNav getStudentFooter(BuildContext context) {
  return GNav(
    backgroundColor: ColorUtil.red,
    color: Colors.white,
    activeColor: ColorUtil.darkRed,
    iconSize: 20,
    tabMargin: const EdgeInsets.all(5),
    gap: 5,
    tabBackgroundColor: Colors.white12,
    tabs: [
      GButton(
        icon: Icons.dashboard,
        text: 'Dashboard',
        onPressed: () => context.goNamed(Routes.studentDashboard.toName),
      ),
      const GButton(
        icon: Icons.class_,
        text: 'Courses',
      ),
      const GButton(
        icon: Icons.calendar_month,
        text: 'Calendar',
      ),
      const GButton(
        icon: Icons.person,
        text: 'Profile',
      )
    ],
  );
}
