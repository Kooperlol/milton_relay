import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/routing/routes.dart';

import '../../shared/utils/color_util.dart';
import '../../shared/utils/display_util.dart';

class AdminFooter extends StatefulWidget {
  final String location;
  final Widget child;

  const AdminFooter({Key? key, required this.child, required this.location})
      : super(key: key);

  @override
  State<AdminFooter> createState() => _AdminFooterState();
}

class _AdminFooterState extends State<AdminFooter> {
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
        onTap: (index) => _goToTab(context, index),
        currentIndex: _index,
        items: nav,
      ),
    );
  }

  void _goToTab(BuildContext context, int index) {
    if (index == _index) return;
    GoRouter router = GoRouter.of(context);
    router.go(nav[index].location);
    setState(() => _index = index);
  }

  static List<NavBarItem> nav = [
    NavBarItem(
        icon: const Icon(Icons.newspaper), location: Routes.adminNews.toPath),
    NavBarItem(
        icon: const Icon(Icons.photo), location: Routes.adminNews.toPath),
    NavBarItem(
        icon: const Icon(Icons.calendar_month),
        location: Routes.adminCalendar.toPath),
    NavBarItem(
        icon: const Icon(Icons.group),
        location: Routes.userManagerScreen.toPath),
    NavBarItem(
        icon: const Icon(Icons.warning), location: Routes.adminNews.toPath),
  ];
}
