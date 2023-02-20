import 'package:flutter/material.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';

import '../../shared/routing/routes.dart';

class IssueManagerScreen extends StatefulWidget {
  const IssueManagerScreen({Key? key}) : super(key: key);

  @override
  State<IssueManagerScreen> createState() => _IssueManagerScreenState();
}

class _IssueManagerScreenState extends State<IssueManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: getAppBar("Issues"));
  }
}
