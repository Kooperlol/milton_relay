import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:milton_relay/parent/models/parent.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/shared/widgets/card.dart';

import '../utils/collections.dart';
import '../../student/models/student.dart';

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
      appBar: getAppBar(),
      body: Column(
          children: children.isEmpty
              ? [const CircularProgressIndicator()]
              : children),
    );
  }

  void _setChildrenData() async {
    List<Widget> childrenData = [];
    CollectionReference users =
        FirebaseFirestore.instance.collection(Collections.users.toPath);
    for (String child in widget.parent.children) {
      DocumentSnapshot doc = await users.doc(child).get();
      childrenData.add(UserCard(
          user: StudentModel.fromJson(doc.data() as Map<String, dynamic>)));
    }
    setState(() => children = childrenData);
  }
}
