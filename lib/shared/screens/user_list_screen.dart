import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/parent/services/parent_service.dart';
import 'package:milton_relay/shared/models/load_model.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/models/collections.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/shared/widgets/user_card_widget.dart';

import '../models/roles.dart';
import '../routing/routes.dart';
import '../../student/services/student_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> with LoadModel {
  @override
  void initState() {
    super.initState();
    fetchData(10);
  }

  @override
  Widget build(BuildContext context) {
    IconButton addUserButton = IconButton(
        tooltip: 'Add User',
        onPressed: () {
          context.push(Routes.addUser.toPath);
          GoRouter.of(context).addListener(_refreshUsersOnPop);
        },
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white));
    IconButton viewAbsencesButton = IconButton(
        tooltip: 'View Absences',
        onPressed: () => context.push(Routes.absenceManager.toPath),
        icon: const Icon(Icons.person_off, color: Colors.white));
    return Scaffold(
      appBar: AuthService().isAdmin()
          ? AppBarWidget(
              title: 'User Manager', icons: [viewAbsencesButton, addUserButton])
          : const AppBarWidget(title: 'User List'),
      body: getDisplay(10),
    );
  }

  void _refreshUsersOnPop() {
    if (!mounted) return;
    if (GoRouter.of(context).location == Routes.adminUserManager.toPath) {
      setState(() {
        data.clear();
        lastDocument = null;
        isAllFetched = false;
      });
      fetchData(10);
      GoRouter.of(context).removeListener(_refreshUsersOnPop);
    }
  }

  @override
  Future<void> fetchData(int loadSize) async {
    if (isLoading || isAllFetched) return;
    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection(Collections.users.toPath)
        .orderBy('lastName');
    query = lastDocument == null
        ? query.limit(loadSize)
        : query.startAfterDocument(lastDocument!).limit(loadSize);

    List<Widget> userCards = [];
    await query.get().then((value) async {
      value.docs.isNotEmpty
          ? lastDocument = value.docs.last
          : lastDocument = null;
      for (var doc in value.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        switch (roleFromString(data['role'])) {
          case Roles.student:
            userCards.add(UserCard(StudentService().getStudentFromJson(data)));
            break;
          case Roles.parent:
            userCards.add(UserCard(ParentService().getParentFromJson(data)));
            break;
          case Roles.instructor:
            userCards.add(UserCard(UserService().getUserFromJson(data)));
            break;
          case Roles.admin:
        }
      }
    });

    if (!mounted) return;
    setState(() {
      data.addAll(userCards);
      isAllFetched = userCards.length < loadSize;
      isLoading = false;
    });
  }
}
