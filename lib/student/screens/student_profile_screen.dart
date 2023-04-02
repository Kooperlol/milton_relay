import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/shared/widgets/user_card_widget.dart';
import 'package:milton_relay/student/models/student_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/utils/color_util.dart';
import '../models/laude_roles.dart';
import '../services/student_service.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  // Stores the instance of the student and their data.
  StudentModel? student;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Your Profile'),
      body: Padding(
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          children: [
            // Gets the user card of the student.
            student != null
                ? UserCard(student!)
                : Center(
                    child: SizedBox(
                        width: 10.w,
                        height: 10.w,
                        child: const CircularProgressIndicator()),
                  ),
            SizedBox.square(dimension: 3.w),
            Card(
              margin: EdgeInsets.all(1.w),
              color: ColorUtil.snowWhite,
              shadowColor: Colors.black,
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(1.5.w),
                child: Column(
                  children: [
                    // Shows the laude role the user is on track to graduate as.
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            children: <TextSpan>[
                              const TextSpan(
                                text:
                                    'You’re currently on the path to graduate as: ',
                              ),
                              TextSpan(
                                  text: getLaudeRole(student!) == null
                                      ? 'N/A'
                                      : getLaudeRole(student!)!.toName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ColorUtil.blue))
                            ],
                            style:
                                TextStyle(fontSize: 4.w, color: Colors.black))),
                    SizedBox.square(dimension: 5.w),
                    SvgPicture.asset('assets/education.svg',
                        width: 30.w, height: 30.w),
                  ],
                ),
              ),
            ),
            SizedBox.square(dimension: 3.w),
            Text('Calculate Your Laude Points',
                style: TextStyle(fontSize: 4.w)),
            SizedBox.square(dimension: 1.w),
            // Button which on click will show the user a screen to re/calculate their laude points.
            GFButton(
                onPressed: () {
                  if (student == null) return;
                  GoRouter.of(context)
                      .push(Routes.studentLaudePointCalculator.toPath);
                  GoRouter.of(context).addListener(_refreshProfileOnView);
                },
                text: 'Calculate',
                icon: Icon(Icons.calculate, color: Colors.white, size: 5.w),
                textStyle: TextStyle(fontSize: 4.w),
                size: 7.w,
                color: ColorUtil.red)
          ],
        ),
      ),
    );
  }

  /// Listener to check for the laude point calculator being exited.
  ///
  /// Once exited, the [_initUser] function is called and the listener is removed.
  void _refreshProfileOnView() {
    if (!mounted) return;
    if (GoRouter.of(context).location == Routes.studentProfile.toPath) {
      _initUser();
      GoRouter.of(context).removeListener(_refreshProfileOnView);
    }
  }

  /// Sets [student] to a Student Model from the data of the user from their AuthService ID.
  void _initUser() async {
    StudentModel studentModel = StudentService().getStudentFromJson(
        await UserService().getDataFromID(AuthService().getUID()));
    setState(() => student = studentModel);
  }
}
