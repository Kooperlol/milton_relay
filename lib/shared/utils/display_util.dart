import 'dart:io';

import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milton_relay/shared/models/user_model.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/utils/color_util.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'roles.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorUtil.red,
      behavior: SnackBarBehavior.floating,
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.info_outline, color: ColorUtil.darkRed, size: 4.w),
        SizedBox.square(
          dimension: 1.w,
        ),
        Flexible(
          child: Text(text,
              maxLines: 2,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: 3.w,
              )),
        ),
      ]),
    ),
  );
}

Widget createButton(String text, double width, Function onTap,
        {IconData? icon, Color? color}) =>
    DropShadow(
        blurRadius: 3,
        opacity: 0.5,
        child: InkWell(
            onTap: () => onTap.call(),
            customBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
                width: width,
                color: color ?? ColorUtil.red,
                padding: EdgeInsets.all(3.w),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) Icon(icon, color: Colors.white),
                        if (icon != null) SizedBox.square(dimension: 1.w),
                        Text(text, style: const TextStyle(color: Colors.white))
                      ]),
                ))));

class NavBarItem extends BottomNavigationBarItem {
  final String location;

  const NavBarItem({required this.location, required Widget icon})
      : super(icon: icon, label: '');
}

Future<File?> pickImage() async {
  final XFile? image =
      await ImagePicker().pickImage(source: ImageSource.gallery);
  if (image == null) return null;
  return File(image.path);
}

void redirectToDashboard(BuildContext context) async {
  if (AuthService().isAdmin()) {
    context.go(Routes.adminNews.toPath);
    return;
  }
  UserModel? user = await AuthService().userModel;
  assert(user != null);
  if (!context.mounted) return;
  context.go(Routes.values
      .firstWhere((element) => element.name == '${user!.role.toName}News')
      .toPath);
}
