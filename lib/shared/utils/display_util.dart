import 'package:flutter/material.dart';
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

class NavBarItem extends BottomNavigationBarItem {
  final String location;

  const NavBarItem({required this.location, required Widget icon})
      : super(icon: icon, label: '');
}
