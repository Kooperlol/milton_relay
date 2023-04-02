import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../utils/color_util.dart';
import '../utils/display_util.dart';

class RelayNavigationBar extends StatefulWidget {
  // Stores the initial location.
  final String location;
  // Stores the initial screen to show which will change when [_goToTab] is called.
  final Widget child;
  // Stores each item to display on the navigation bar.
  final List<NavBarItem> nav;

  const RelayNavigationBar(
      {Key? key,
      required this.child,
      required this.location,
      required this.nav})
      : super(key: key);

  @override
  State<RelayNavigationBar> createState() => _RelayNavigationBarState();
}

class _RelayNavigationBarState extends State<RelayNavigationBar> {
  // Stores the current index of the navigation bar.
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

  /// Makes GoRouter switch to the navigation bar location of [index].
  void _goToTab(BuildContext context, int index) {
    // If the index did not change, do nothing.
    if (index == _index) return;
    // Make GoRouter change to the location of the navbar.
    GoRouter.of(context).go(widget.nav[index].location);
    // Update the index of the navigation bar.
    setState(() => _index = index);
  }
}
