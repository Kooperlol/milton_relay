import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/shared/widgets/user_card_widget.dart';
import 'package:milton_relay/student/models/student.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/utils/color_util.dart';
import '../services/student_service.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  StudentModel? student;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Your Profile'),
      body: Padding(
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          children: [
            student != null
                ? UserCard(student!)
                : Center(
                    child: SizedBox(
                        width: 10.w,
                        height: 10.w,
                        child: const CircularProgressIndicator()),
                  ),
            SizedBox.square(dimension: 3.w),
            Text('Calculate Your Laude Points',
                style: TextStyle(fontSize: 4.w)),
            SizedBox.square(dimension: 1.w),
            GFButton(
                onPressed: () {
                  GoRouter.of(context)
                      .push(Routes.studentLaudePointCalculator.toPath);
                  GoRouter.of(context).addListener(_refreshProfileOnView);
                },
                text: 'Calculate',
                textStyle: TextStyle(fontSize: 4.w),
                size: 7.w,
                color: ColorUtil.red)
          ],
        ),
      ),
    );
  }

  void _refreshProfileOnView() {
    if (!mounted) return;
    if (GoRouter.of(context).location == Routes.studentProfile.toPath) {
      initUser();
      GoRouter.of(context).removeListener(_refreshProfileOnView);
    }
  }

  void initUser() async {
    StudentModel studentModel = StudentService().getStudentFromJson(
        await UserService().getDataFromID(AuthService().getUID()));
    setState(() => student = studentModel);
  }
}
