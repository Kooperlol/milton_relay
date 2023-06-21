import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milton_relay/shared/models/user_model.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/utils/color_util.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../models/roles.dart';

/// Shows a snack bar with a message of [text].
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
        BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorUtil.red,
        behavior: SnackBarBehavior.floating,
        content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.info_outline, color: Colors.white, size: 5.w),
          SizedBox.square(
            dimension: 1.w,
          ),
          Flexible(
            child: Text(text,
                maxLines: 2,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 3.5.w,
                )),
          ),
        ]),
      ),
    );

/// Widget that creates a [BottomNavigationBarItem] from giving a [location] and [icon].
class NavBarItem extends BottomNavigationBarItem {
  final String location;

  const NavBarItem({required this.location, required Widget icon})
      : super(icon: icon, label: '');
}

/// Image picker, which shows the user their image gallery.
Future<File?> pickImage() async {
  final XFile? image =
      await ImagePicker().pickImage(source: ImageSource.gallery);
  if (image == null) return null;
  return File(image.path);
}

/// Gets the user's role and sends them to their corresponding news page.
///
/// Initiates their bottom navigation bar.
void redirectToDashboard(BuildContext context) async {
  if (AuthService().isAdmin()) {
    context.go(Routes.adminNews.toPath);
    return;
  }
  UserModel user = await AuthService().userModel;
  // ignore: use_build_context_synchronously
  if (!context.mounted) return;
  context.go(Routes.values
      .firstWhere((element) => element.name == '${user.role.toName}News')
      .toPath);
}
