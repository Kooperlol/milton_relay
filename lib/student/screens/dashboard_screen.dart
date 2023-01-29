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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Latest Feed', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
