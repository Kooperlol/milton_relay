import 'package:flutter/material.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/student/widgets/footer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      bottomNavigationBar: getStudentFooter(context),
    );
  }
}
