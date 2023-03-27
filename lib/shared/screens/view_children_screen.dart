import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:milton_relay/parent/models/parent_model.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/shared/widgets/user_card_widget.dart';
import 'package:milton_relay/student/services/student_service.dart';

import '../models/collections.dart';

class ViewChildrenScreen extends StatefulWidget {
  final ParentModel parent;

  const ViewChildrenScreen({Key? key, required this.parent}) : super(key: key);

  @override
  State<ViewChildrenScreen> createState() => _ViewChildrenScreenState();
}

class _ViewChildrenScreenState extends State<ViewChildrenScreen> {
  List<Widget> children = [];

  @override
  void initState() {
    super.initState();
    _setChildrenData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Children'),
      body: Column(
          children: children.isEmpty
              ? [const Center(child: CircularProgressIndicator())]
              : children),
    );
  }

  void _setChildrenData() async {
    List<Widget> childrenData = [];
    CollectionReference users =
        FirebaseFirestore.instance.collection(Collections.users.toPath);
    for (String child in widget.parent.children) {
      DocumentSnapshot doc = await users.doc(child).get();
      childrenData.add(UserCard(StudentService()
          .getStudentFromJson(doc.data() as Map<String, dynamic>)));
    }
    setState(() => children = childrenData);
  }
}
