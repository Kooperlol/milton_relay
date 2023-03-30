import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
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
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: GFListTile(
              title: const Text('Logout'),
              icon: const Icon(Icons.logout),
              onTap: () => AuthService().logout(context),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: GFListTile(
              title: const Text('Report an Issue'),
              icon: const Icon(Icons.warning),
              onTap: () => GoRouter.of(context).push(Routes.reportIssue.toPath),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: GFListTile(
              title: const Text('Contact the School'),
              icon: const Icon(Icons.phone),
              onTap: () => launchUrl(Uri(scheme: 'tel', path: '608 868 9200')),
            ),
          )
        ],
      ),
    );
  }
}
