import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
import '../models/laude_roles.dart';
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
    _initUser();
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
            Card(
              margin: EdgeInsets.all(1.w),
              color: ColorUtil.snowWhite,
              shadowColor: Colors.black,
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(1.5.w),
                child: Column(
                  children: [
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            children: <TextSpan>[
                              const TextSpan(
                                text:
                                    'You’re currently on the path to graduate as: ',
                              ),
                              TextSpan(
                                  text: _getLaudeRole() == null
                                      ? 'N/A'
                                      : _getLaudeRole()!.toName,
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
      _initUser();
      GoRouter.of(context).removeListener(_refreshProfileOnView);
    }
  }

  LaudeRoles? _getLaudeRole() {
    if (student == null) return null;
    if (student!.laudePoints >= 60) return LaudeRoles.summaCumLaude;
    if (student!.laudePoints >= 40) return LaudeRoles.magnaCumLaude;
    if (student!.laudePoints >= 20) return LaudeRoles.cumLaude;
    return LaudeRoles.normal;
  }

  void _initUser() async {
    StudentModel studentModel = StudentService().getStudentFromJson(
        await UserService().getDataFromID(AuthService().getUID()));
    setState(() => student = studentModel);
  }
}
