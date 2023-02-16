import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

AppBar getAppBar() {
  return AppBar(
    backgroundColor: const Color.fromRGBO(159, 48, 47, 1),
    toolbarHeight: 10.w,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/miltonrelay-transparent.png',
          height: 15.w,
          width: 15.w,
        ),
        SizedBox.square(dimension: 2.w),
        Text(
          'Milton Relay',
          style: TextStyle(fontFamily: 'Lato', fontSize: 7.w),
        ),
      ],
    ),
  );
}

AppBar getAppBarWithIconRight(IconButton icon) {
  return AppBar(
    backgroundColor: const Color.fromRGBO(159, 48, 47, 1),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/miltonrelay-transparent.png',
          height: 15.w,
          width: 15.w,
        ),
        SizedBox.square(dimension: 2.w),
        Text(
          'Milton Relay',
          style: TextStyle(fontFamily: 'Lato', fontSize: 7.w),
        ),
        SizedBox.square(dimension: 5.w),
        icon
      ],
    ),
  );
}

AppBar getAppBarWithIconLeft(IconButton icon) {
  return AppBar(
    backgroundColor: const Color.fromRGBO(159, 48, 47, 1),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        SizedBox.square(dimension: 5.w),
        Image.asset(
          'assets/miltonrelay-transparent.png',
          height: 15.w,
          width: 15.w,
        ),
        SizedBox.square(dimension: 2.w),
        Text(
          'Milton Relay',
          style: TextStyle(fontFamily: 'Lato', fontSize: 7.w),
        )
      ],
    ),
  );
}
