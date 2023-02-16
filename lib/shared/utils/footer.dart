import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'color_util.dart';
import 'display_util.dart';

class Footer extends StatefulWidget {
  final String location;
  final Widget child;
  final List<NavBarItem> nav;

  const Footer(
      {Key? key,
      required this.child,
      required this.location,
      required this.nav})
      : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: ColorUtil.darkRed,
        backgroundColor: ColorUtil.red,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        iconSize: 5.w,
        onTap: (index) => _goToTab(context, index),
        currentIndex: _index,
        items: widget.nav,
      ),
    );
  }

  void _goToTab(BuildContext context, int index) {
    if (index == _index) return;
    GoRouter router = GoRouter.of(context);
    router.go(widget.nav[index].location);
    setState(() => _index = index);
  }
}
