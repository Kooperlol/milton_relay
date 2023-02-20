import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:milton_relay/shared/models/issue_model.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/services/issue_service.dart';
import 'package:milton_relay/shared/utils/display_util.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:uuid/uuid.dart';

import '../routing/routes.dart';
import '../utils/collections.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({Key? key}) : super(key: key);

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final TextEditingController _descriptionInput = TextEditingController();
  final List<File> _images = [];
  String? _issueValue;

  @override
  void dispose() {
    super.dispose();
    _descriptionInput.dispose();
  }

  void _submitReport() async {
    if (_issueValue == null || _descriptionInput.text.isEmpty) {
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    if (_descriptionInput.text.characters.length > 750) {
      showSnackBar(
          context, "The description can't be greater than 750 characters!");
      return;
    }

    context.loaderOverlay.show();

    var uuid = const Uuid();
    var id = uuid.v1();

    try {
      if (_images.isNotEmpty) {
        for (var image in _images) {
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child("issues/$id/${image.path.split('/').last}");
          await storageRef.putFile(image);
        }
      }

      CollectionReference issuesCollection =
          FirebaseFirestore.instance.collection(Collections.issues.toPath);
      IssueModel issueModel = IssueModel(
          issueFromString(_issueValue!.toLowerCase()),
          _descriptionInput.text,
          AuthService().getUID(),
          DateTime.now(),
          false);
      await issuesCollection
          .doc(id)
          .set(IssueService().issueToJson(issueModel));
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to create an issue report: ${error.toString()}");
    }

    if (!mounted) return;
    showSnackBar(context, "Created Report. Thanks for your feedback!");
    context.loaderOverlay.hide();

    setState(() {
      _descriptionInput.clear();
      _issueValue = null;
      _images.clear();
    });
  }

  void _attachContent() async {
    File? file = await pickImage();
    if (file == null) return;
    setState(() => _images.add(file));
    if (!mounted) return;
    showSnackBar(context, 'You have uploaded an image!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Report Issue'),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox.square(dimension: 3.w),
              SvgPicture.asset('assets/issue-vector.svg',
                  width: 200.w, height: 50.w),
              SizedBox.square(dimension: 3.w),
              DropdownButton(
                style: TextStyle(fontSize: 4.w, color: Colors.black),
                iconSize: 4.w,
                hint: const Text('Type of issue'),
                value: _issueValue,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                onChanged: (String? value) {
                  setState(() => {_issueValue = value ?? ""});
                },
                items: Issues.values
                    .map((e) => e.toName.capitalize())
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox.square(dimension: 3.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: TextField(
                  maxLines: null,
                  controller: _descriptionInput,
                  style: TextStyle(fontSize: 2.5.w),
                  decoration: InputDecoration(
                      icon: Icon(Icons.description, size: 6.w),
                      labelText: 'Description',
                      labelStyle: TextStyle(fontSize: 3.w)),
                ),
              ),
              SizedBox.square(dimension: 3.w),
              createButton('Attach Photos', 35.w, () {
                if (_images.length >= 3) {
                  showSnackBar(
                      context, 'The maximum number of attachments is 3!');
                  return;
                }
                _attachContent();
              }, icon: Icons.add_photo_alternate),
              SizedBox.square(dimension: 3.w),
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Center(
                      child: TextButton(
                    child: Text(_images[index].path.split('/').last,
                        style: TextStyle(fontSize: 2.w)),
                    onPressed: () {
                      context.push(Routes.viewImageScreen.toPath,
                          extra: _images[index]);
                    },
                  ));
                },
                itemCount: _images.length,
              ),
              SizedBox.square(dimension: 3.w),
              createButton('Submit Report', 50.w, () => _submitReport(),
                  icon: Icons.send)
            ],
          ),
        ),
      ),
    );
  }
}
