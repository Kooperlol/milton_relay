import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:milton_relay/parent/models/parent_model.dart';
import 'package:milton_relay/parent/services/parent_service.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/shared/widgets/user_card_widget.dart';
import 'package:milton_relay/student/models/student_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/routing/routes.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_service.dart';
import '../../student/services/student_service.dart';

class FamilyManagerScreen extends StatefulWidget {
  const FamilyManagerScreen({Key? key}) : super(key: key);

  @override
  State<FamilyManagerScreen> createState() => _FamilyManagerScreenState();
}

class _FamilyManagerScreenState extends State<FamilyManagerScreen> {
  List<Widget> studentCards = [];
  ParentModel? parent;

  @override
  void initState() {
    super.initState();
    context.loaderOverlay.show();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Your Family'),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return studentCards[index];
        },
        itemCount: studentCards.length,
      ),
    );
  }

  void _initData() async {
    ParentModel parentModel = ParentService().getParentFromJson(
        await UserService().getDataFromID(AuthService().getUID()));

    final List<Widget> cards = [];
    for (String child in parentModel.children) {
      StudentModel student = await StudentService()
          .getStudentFromJson(await UserService().getDataFromID(child));
      cards.add(
        UserCard(student,
            icon: DropdownButtonHideUnderline(
              child: DropdownButton(
                icon: Icon(Icons.more_vert, size: 5.w),
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Row(children: [
                      const Icon(Icons.list),
                      SizedBox(width: 1.w),
                      const Text('View Absences')
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Row(children: [
                      const Icon(Icons.notification_important),
                      SizedBox(width: 1.w),
                      const Text('Report Absence')
                    ]),
                  )
                ],
                onChanged: (int? value) {
                  if (value == 0) {
                    GoRouter.of(context)
                        .push(Routes.viewAbsences.toPath, extra: student);
                  }
                  if (value == 1) {
                    GoRouter.of(context)
                        .push(Routes.reportAbsence.toPath, extra: student);
                    GoRouter.of(context).addListener(_refreshListOnPop);
                  }
                },
              ),
            )),
      );
    }

    setState(() {
      parent = parentModel;
      studentCards = cards;
    });

    if (!mounted) return;
    context.loaderOverlay.hide();
  }

  void _refreshListOnPop() {
    if (!mounted) return;
    if (GoRouter.of(context).location == Routes.familyManager.toPath) {
      _initData();
      GoRouter.of(context).removeListener(_refreshListOnPop);
    }
  }
}
