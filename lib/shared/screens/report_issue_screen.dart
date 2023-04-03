import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/dropdown/gf_dropdown.dart';
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
import '../models/collections.dart';
import '../utils/color_util.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({Key? key}) : super(key: key);

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  // Text widget for description of issue.
  final TextEditingController _descriptionInput = TextEditingController();
  // Images that will be stored for the issue.
  final List<File> _images = [];
  // The type of issue being reported.
  String? _issueValue;

  /// Disposes the text field.
  @override
  void dispose() {
    super.dispose();
    _descriptionInput.dispose();
  }

  /// Submits the report to the issues collection.
  Future<void> _submitReport() async {
    // Checks to make sure that all input fields are filled out.
    if (_issueValue == null || _descriptionInput.text.isEmpty) {
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    // Makes sure that the description is less than 750 characters.
    if (_descriptionInput.text.characters.length > 750) {
      showSnackBar(
          context, "The description can't be greater than 750 characters!");
      return;
    }

    // Displays a loading overlay.
    context.loaderOverlay.show();

    // Creates a unique ID for the post.
    var uuid = const Uuid();
    var id = uuid.v1();

    List<String> imageURLs = [];
    try {
      // Makes sure the user submitted an image.
      if (_images.isNotEmpty) {
        // Traverses through each image and adds it to the Firestore database.
        // Stores the URL of each image in the [imageURLs] array.
        for (var image in _images) {
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child("issues/$id/${image.path.split('/').last}");
          await storageRef.putFile(image);
          imageURLs.add(await storageRef.getDownloadURL());
        }
      }

      // Creates an Issue Model and uploads it to the database.
      CollectionReference issuesCollection =
          FirebaseFirestore.instance.collection(Collections.issues.toPath);
      IssueModel issueModel = IssueModel(
          id,
          issueFromString(_issueValue!.toLowerCase()),
          _descriptionInput.text,
          AuthService().getUID(),
          DateTime.now(),
          false,
          imageURLs);
      await issuesCollection
          .doc(id)
          .set(IssueService().issueToJson(issueModel));
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to create an issue report: ${error.toString()}");
    }

    // If the screen is still mounted, it will display a success message and hide the load overlay.
    if (!mounted) return;
    showSnackBar(context, "Created Report. Thanks for your feedback!");
    context.loaderOverlay.hide();

    // Resets all input values.
    setState(() {
      _descriptionInput.clear();
      _issueValue = null;
      _images.clear();
    });
  }

  /// Adds an image to [_images] based on user input.
  void _addImage() async {
    File? file = await pickImage();
    if (file == null) return;
    setState(() => _images.add(file));
    if (!mounted) return;
    showSnackBar(context, 'You have uploaded an image!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Report Issue'),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox.square(dimension: 3.w),
              // Report Issue Vector.
              SvgPicture.asset('assets/issue-vector.svg',
                  width: 200.w, height: 50.w),
              SizedBox.square(dimension: 3.w),
              Card(
                margin: EdgeInsets.all(3.w),
                color: ColorUtil.snowWhite,
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 10.w,
                        child: DropdownButtonHideUnderline(
                          // Dropdown which displays the different types of issues.
                          child: GFDropdown(
                            dropdownButtonColor: ColorUtil.snowWhite,
                            dropdownColor: ColorUtil.snowWhite,
                            padding: EdgeInsets.all(1.5.w),
                            borderRadius: BorderRadius.circular(2.w),
                            border:
                                BorderSide(color: Colors.black12, width: 0.1.w),
                            hint: const Text('Type of issue'),
                            value: _issueValue,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.black),
                            onChanged: (value) {
                              // Updates the issue value.
                              // Will remain as hint text if nothing was selected.
                              setState(() => {_issueValue = value ?? ""});
                            },
                            // Displays each field within the Issues enum.
                            items: Issues.values
                                .map((e) => e.toName.capitalize())
                                .map<DropdownMenuItem<dynamic>>((String value) {
                              return DropdownMenuItem<dynamic>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox.square(dimension: 3.w),
                      // Description input.
                      TextField(
                        maxLines: null,
                        controller: _descriptionInput,
                        style: TextStyle(fontSize: 2.5.w),
                        decoration: InputDecoration(
                            icon: Icon(Icons.description, size: 6.w),
                            labelText: 'Description',
                            labelStyle: TextStyle(fontSize: 3.w)),
                      ),
                      SizedBox.square(dimension: 3.w),
                      // Button to add images.
                      // On pressed, this will call the [_addImage] function.
                      GFButton(
                          onPressed: () {
                            // Does not call the function if the user has already attached 3 images.
                            if (_images.length >= 3) {
                              showSnackBar(context,
                                  'The maximum number of attachments is 3!');
                              return;
                            }
                            _addImage();
                          },
                          text: 'Attach Photos',
                          textStyle: TextStyle(fontSize: 3.w),
                          size: 6.w,
                          padding: EdgeInsets.all(1.w),
                          color: ColorUtil.red,
                          icon: Icon(Icons.add_photo_alternate,
                              color: Colors.white, size: 3.w)),
                    ],
                  ),
                ),
              ),
              SizedBox.square(dimension: 3.w),
              // Shows a list of the images attached.
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Center(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                    // Delete button which removes the image from the list on tap.
                    IconButton(
                        onPressed: () =>
                            setState(() => _images.removeAt(index)),
                        icon: Icon(Icons.delete, color: ColorUtil.red)),
                    TextButton(
                      child: Text(_images[index].path.split('/').last,
                          style: TextStyle(fontSize: 2.w)),
                      // Displays the image in a new screen on tap
                      onPressed: () {
                        context.push(Routes.viewImage.toPath,
                            extra: _images[index]);
                      },
                    ),
                  ]));
                },
                itemCount: _images.length,
              ),
              SizedBox.square(dimension: 3.w),
              // Submit button that calls the [_submitReport] function on tap.
              GFButton(
                  onPressed: _submitReport,
                  icon: Icon(Icons.send, color: Colors.white, size: 4.w),
                  textStyle: TextStyle(fontSize: 4.w),
                  size: 8.w,
                  padding: EdgeInsets.all(1.w),
                  text: 'Submit Report',
                  color: ColorUtil.red),
              SizedBox.square(dimension: 3.w)
            ],
          ),
        ),
      ),
    );
  }
}
