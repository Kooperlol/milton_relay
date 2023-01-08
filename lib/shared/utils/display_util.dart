import 'package:flutter/material.dart';
import 'package:milton_relay/shared/utils/color_util.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorUtil.red,
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error, color: ColorUtil.darkRed, size: 30),
        const SizedBox.square(
          dimension: 5,
        ),
        Text(text,
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
              fontFamily: 'Lato',
              fontSize: 18,
            )),
      ]),
    ),
  );
}
