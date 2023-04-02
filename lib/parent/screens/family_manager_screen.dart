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
  // Stores the [UserCard] of the [parent]'s children.
  List<Widget> _childrenCards = [];
  // Stores the parent model which is declared in [_initData].
  ParentModel? _parent;

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
      // Displays the [_childrenCards] list.
      body: ListView.builder(
        itemBuilder: (context, index) {
          return _childrenCards[index];
        },
        itemCount: _childrenCards.length,
      ),
    );
  }

  /// Gets the parent from [AuthService] current UID and then traverses through the children to get their cards.
  void _initData() async {
    ParentModel parentModel = ParentService().getParentFromJson(
        await UserService().getDataFromID(AuthService().getUID()));

    final List<Widget> cards = [];
    for (String child in parentModel.children) {
      StudentModel student = StudentService()
          .getStudentFromJson(await UserService().getDataFromID(child));
      cards.add(
        UserCard(student,
            // Creates a three dot vertical button to view absences or report an absence.
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
                // When a dropdown value is selected, the parent is redirected to the corresponding screen.
                onChanged: (int? value) {
                  if (value == 0) {
                    GoRouter.of(context)
                        .push(Routes.viewAbsences.toPath, extra: student);
                  }
                  if (value == 1) {
                    GoRouter.of(context)
                        .push(Routes.reportAbsence.toPath, extra: student);
                    // Add listener to refresh data when the report absence screen is exited.
                    GoRouter.of(context).addListener(_refreshListOnPop);
                  }
                },
              ),
            )),
      );
    }

    // Updates the current state of the screen with the new data.
    setState(() {
      _parent = parentModel;
      _childrenCards = cards;
    });

    // If the screen is still mounted, the loading overlay is hidden.
    if (!mounted) return;
    context.loaderOverlay.hide();
  }

  /// Listener to check for the report absence screen being exited.
  ///
  /// Once exited, the [_initData] function is called and the listener is removed.
  void _refreshListOnPop() {
    if (!mounted) return;
    if (GoRouter.of(context).location == Routes.familyManager.toPath) {
      _initData();
      GoRouter.of(context).removeListener(_refreshListOnPop);
    }
  }
}
