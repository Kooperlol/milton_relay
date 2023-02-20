import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

AppBar getAppBar(String title, {IconButton? leftIcon, IconButton? rightIcon}) {
  return AppBar(
    leading: leftIcon,
    elevation: 15,
    toolbarHeight: 8.w,
    actions: rightIcon == null ? [] : [rightIcon],
    backgroundColor: const Color.fromRGBO(159, 48, 47, 1),
    centerTitle: true,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/miltonrelay-logo.png',
          height: 10.w,
          width: 10.w,
        ),
        SizedBox.square(dimension: 1.w),
        Text(
          title,
          style: TextStyle(fontFamily: 'Lato', fontSize: 6.5.w),
        ),
      ],
    ),
  );
}
