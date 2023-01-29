import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/admin/widgets/footer.dart';
import 'package:milton_relay/parent/services/parent_service.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/utils/collections.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/shared/widgets/card.dart';

import '../../shared/models/roles.dart';
import '../../shared/routing/routes.dart';
import '../../student/services/student_service.dart';

class UserManagerScreen extends StatefulWidget {
  const UserManagerScreen({Key? key}) : super(key: key);

  @override
  State<UserManagerScreen> createState() => _UserManagerScreenState();
}

class _UserManagerScreenState extends State<UserManagerScreen> {
  static const int loadSize = 15;
  final List<Widget> _data = [];
  bool _allFetched = false, _isLoading = false;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    IconButton iconButton = IconButton(
        onPressed: () => context.push(Routes.addUserScreen.toPath),
        icon:
            const Icon(Icons.person_add_alt_1, size: 45, color: Colors.white));
    return Scaffold(
      appBar: getAppBarWithIconRight(iconButton),
      bottomNavigationBar: getAdminFooter(context),
      body: NotificationListener<ScrollEndNotification>(
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (index == _data.length) {
              return const SizedBox(
                key: ValueKey('loading'),
                width: double.infinity,
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _data[index];
          },
          itemCount: _data.length + (_allFetched ? 0 : 1),
        ),
        onNotification: (scrollEnd) {
          if (scrollEnd.metrics.atEdge && scrollEnd.metrics.pixels > 0) {
            _getUserData();
          }
          return true;
        },
      ),
    );
  }

  Future<void> _getUserData() async {
    if (_isLoading || _allFetched) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection(Collections.users.toPath)
        .orderBy('id');
    query = _lastDocument == null
        ? query.limit(loadSize)
        : query.startAfterDocument(_lastDocument!).limit(loadSize);

    List<Widget> userCards = [];
    await query.get().then((value) {
      value.docs.isNotEmpty
          ? _lastDocument = value.docs.last
          : _lastDocument = null;
      for (var e in value.docs) {
        Map<String, dynamic> data = e.data() as Map<String, dynamic>;
        switch (roleFromString(data['role'])) {
          case Roles.student:
            userCards
                .add(UserCard(user: StudentService().getStudentFromJson(data)));
            break;
          case Roles.parent:
            userCards
                .add(UserCard(user: ParentService().getParentFromJson(data)));
            break;
          case Roles.instructor:
            userCards.add(UserCard(user: UserService().getUserFromJson(data)));
            break;
          case Roles.admin:
        }
      }
    });

    setState(() {
      _data.addAll(userCards);
      if (userCards.length < loadSize) _allFetched = true;
      _isLoading = false;
    });
  }
}
