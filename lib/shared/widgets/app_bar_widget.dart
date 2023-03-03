import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../utils/color_util.dart';

AppBar getAppBar(String title, {List<IconButton>? icons}) {
  return AppBar(
    backgroundColor: ColorUtil.red,
    actions: icons,
    titleTextStyle: TextStyle(fontSize: 5.w),
    iconTheme: IconThemeData(size: 5.w, color: Colors.white),
    toolbarHeight: 10.w,
    centerTitle: true,
    title: FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/miltonrelay-logo.png',
            height: 8.w,
            width: 8.w,
          ),
          SizedBox(width: 1.w),
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
