import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:milton_relay/shared/routing/routes.dart';

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
        icon: Icons.newspaper,
        onPressed: () => context.goNamed(Routes.adminNews.toName),
      ),
      const GButton(
        icon: Icons.photo,
      ),
      const GButton(
        icon: Icons.calendar_month,
      ),
      const GButton(
        icon: Icons.person,
      ),
      const GButton(
        icon: Icons.warning,
      )
    ],
  );
}
