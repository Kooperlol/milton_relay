import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routing/routes.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Settings'),
      body: Column(
        children: [
          // Logout Button, which calls [AuthService]'s logout button.
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: GFListTile(
              title: Text('Logout', style: TextStyle(fontSize: 3.w)),
              icon: Icon(Icons.logout, size: 4.w),
              onTap: () => AuthService().logout(context),
            ),
          ),
          // Report an Issue Button, which redirects the user to the issue report screen.
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: GFListTile(
              title: Text('Report an Issue', style: TextStyle(fontSize: 3.w)),
              icon: Icon(Icons.warning, size: 4.w),
              onTap: () => GoRouter.of(context).push(Routes.reportIssue.toPath),
            ),
          ),
          // Contact the school button, which uses url launcher to call the school.
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: GFListTile(
              title:
                  Text('Contact the School', style: TextStyle(fontSize: 3.w)),
              icon: Icon(Icons.phone, size: 4.w),
              onTap: () => launchUrl(Uri(scheme: 'tel', path: '608 868 9200')),
            ),
          )
        ],
      ),
    );
  }
}
