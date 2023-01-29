import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:milton_relay/admin/widgets/footer.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/utils/color_util.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorUtil.red,
      behavior: SnackBarBehavior.floating,
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.info_outline, color: ColorUtil.darkRed, size: 20),
        const SizedBox.square(
          dimension: 5,
        ),
        Flexible(
          child: Text(text,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontFamily: 'Lato',
                fontSize: 18,
              )),
        ),
      ]),
    ),
  );
}

/**GNav getBottomNavBar(BuildContext context) {
  if (AuthService().firebaseUser!.email == "admin@milton.k12.wi.us") {
    return getAdminFooter(context);
  }
}**/
