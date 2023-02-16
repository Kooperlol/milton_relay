import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/models/user.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/utils/color_util.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../models/roles.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorUtil.red,
      behavior: SnackBarBehavior.floating,
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.info_outline, color: ColorUtil.darkRed),
        const SizedBox.square(
          dimension: 5,
        ),
        Flexible(
          child: Text(text,
              maxLines: 2,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: 18,
              )),
        ),
      ]),
    ),
  );
}

Widget createButton(String text, double width, Function onTap) => DropShadow(
    blurRadius: 3,
    opacity: 0.5,
    child: InkWell(
      onTap: () => onTap.call(),
      customBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
          width: width,
          alignment: Alignment.center,
          color: ColorUtil.red,
          padding: EdgeInsets.symmetric(vertical: 3.w),
          child:
              Text(text, style: TextStyle(fontSize: 3.w, color: Colors.white))),
    ));

class NavBarItem extends BottomNavigationBarItem {
  final String location;

  const NavBarItem({required this.location, required Widget icon})
      : super(icon: icon, label: '');
}

void redirectToDashboard(BuildContext context) async {
  if (AuthService().isAdmin()) {
    context.go(Routes.adminNews.toPath);
    return;
  }
  UserModel? user = await AuthService().userModel;
  if (!context.mounted) return;
  assert(user != null);
  context.go(Routes.values
      .firstWhere((element) => element.name == '${user!.role.toName}News')
      .toPath);
}
