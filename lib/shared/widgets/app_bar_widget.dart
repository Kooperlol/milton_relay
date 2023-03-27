import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../utils/color_util.dart';

class AppBarWidget extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final List<IconButton>? icons;

  const AppBarWidget({Key? key, this.icons, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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

  @override
  Size get preferredSize => Size.fromHeight(10.w);
}
