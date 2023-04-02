import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/dropdown/gf_dropdown.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/parent/models/parent_model.dart';
import 'package:milton_relay/parent/services/parent_service.dart';
import 'package:milton_relay/shared/models/roles.dart';
import 'package:milton_relay/shared/models/user_model.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/utils/display_util.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/student/models/student_model.dart';
import 'package:milton_relay/student/services/student_service.dart';
import 'package:multiselect/multiselect.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/models/collections.dart';
import '../../shared/utils/color_util.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  // Text field widgets for user information.
  final TextEditingController _nameController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController(),
      _laudePointsController = TextEditingController();
  // If [_roleValue] is a parent, this stores the results from the children dropdown.
  List<String> _parentChildrenPickerSelected = [];
  // Stores a map with a key of a Student's full name and a value of their ID.
  final Map<String, String> _parentChildrenPickerDisplay = {};
  // Stores the role of the user being created. By default, this is a student.
  String _roleValue = Roles.student.toName;
  // Stores the avatar of the user.
  File? _avatar;

  /// Disposes text field widgets.
  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _laudePointsController.dispose();
  }

  /// Creates a user based on input fields.
  void _createUser() async {
    // Checks to make sure that all input fields are filled out.
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        await _avatar?.exists() == false) {
      if (!mounted) return;
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    // Makes sure the name contains a first and last name.
    List<String> name = _nameController.text.split(" ");
    if (name.length != 2) {
      if (!mounted) return;
      showSnackBar(context, "Invalid name!");
      return;
    }

    // Makes sure the password length is greater than or equal to 6.
    if (_passwordController.text.length < 6) {
      if (!mounted) return;
      showSnackBar(context, "Your password must be 6 characters!");
      return;
    }

    // If specified, this makes sure that the laude points are a valid number.
    if (_laudePointsController.text.isNotEmpty &&
        !isNumeric(_laudePointsController.text)) {
      if (!mounted) return;
      showSnackBar(context, "The value must be numeric!");
      return;
    }

    try {
      // Creates a user in Firebase Authentication.
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      // Adds the avatar to Firestore and gets the link.
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("avatars/${userCredential.user!.uid}");
      TaskSnapshot uploadTask = await storageRef.putFile(_avatar!);

      // Gets the JSON data that corresponds to the [role] of the user.
      CollectionReference users =
          FirebaseFirestore.instance.collection(Collections.users.toPath);
      Roles role = roleFromString(_roleValue);
      Map<String, dynamic> data;
      switch (role) {
        case Roles.instructor:
          data = UserService().userToJson(UserModel(
              userCredential.user!.uid,
              name[0].capitalize(),
              name[1].capitalize(),
              await uploadTask.ref.getDownloadURL(),
              Roles.instructor));
          break;
        case Roles.parent:
          data = ParentService().parentToJson(ParentModel(
              userCredential.user!.uid,
              name[0].capitalize(),
              name[1].capitalize(),
              await uploadTask.ref.getDownloadURL(),
              _parentChildrenPickerSelected
                  .map((e) => _parentChildrenPickerDisplay[e]!)
                  .toList()));
          break;
        case Roles.student:
          data = StudentService().studentToJson(StudentModel(
              userCredential.user!.uid,
              name[0].capitalize(),
              name[1].capitalize(),
              await uploadTask.ref.getDownloadURL(),
              [],
              double.parse(_laudePointsController.text)));
          break;
        case Roles.admin:
          return;
      }
      // Creates a document with the Authentication ID of the user and sets it to [data].
      users.doc(userCredential.user!.uid).set(data);
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to create a new user: ${error.toString()}");
    }

    // If the screen is still mounted, it will display a success message and pop the screen.
    if (!mounted) return;
    showSnackBar(context, "Created user!");

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(title: 'Create a User'),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Creates a dropdown using GetWidget of all roles and a selection feature.
                SizedBox(
                  height: 10.w,
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: GFDropdown(
                        dropdownButtonColor: ColorUtil.snowWhite,
                        dropdownColor: ColorUtil.snowWhite,
                        padding: EdgeInsets.all(1.5.w),
                        borderRadius: BorderRadius.circular(2.w),
                        border: BorderSide(color: Colors.black12, width: 0.1.w),
                        value: _roleValue,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.black),
                        items: Roles.values
                            .where((e) => e != Roles.admin)
                            .map((e) => DropdownMenuItem<dynamic>(
                                  value: e.toName,
                                  child: Text(e.toName.capitalize()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          if (value == Roles.parent.toName &&
                              _parentChildrenPickerDisplay.isEmpty) {
                            _setParentChildrenPickerDisplay();
                          }
                          setState(() => _roleValue = value);
                        }),
                  ),
                ),
                SizedBox.square(dimension: 5.w),
                Card(
                  color: ColorUtil.snowWhite,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      children: [
                        // Avatar selector and display.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 7.5.w,
                              backgroundImage: _avatar == null
                                  ? Image.asset(
                                          "assets/default-user-avatar.jpg")
                                      .image
                                  : Image.file(_avatar!).image,
                            ),
                            SizedBox.square(dimension: 3.w),
                            GFButton(
                                onPressed: () async {
                                  File? image = await pickImage();
                                  setState(() => _avatar = image);
                                },
                                text: 'Upload Avatar',
                                icon: const Icon(Icons.add_photo_alternate,
                                    color: Colors.white),
                                color: ColorUtil.darkGray)
                          ],
                        ),
                        SizedBox.square(dimension: 5.w),
                        // Name Text Field.
                        TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.drive_file_rename_outline),
                                labelText: 'Full Name')),
                        SizedBox.square(dimension: 5.w),
                        // Email Field.
                        TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.email),
                                labelText: 'Email Address')),
                        SizedBox.square(dimension: 5.w),
                        // Password Field.
                        TextField(
                            controller: _passwordController,
                            enableSuggestions: false,
                            autocorrect: false,
                            obscureText: true,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.lock), labelText: 'Password')),
                        SizedBox.square(dimension: 5.w),
                        // Children dropdown if [_roleValue] is equal to Parent.
                        if (_roleValue == Roles.parent.toName)
                          Column(children: [
                            SizedBox.square(dimension: 5.w),
                            DropDownMultiSelect(
                                options:
                                    _parentChildrenPickerDisplay.keys.toList(),
                                selectedValues: _parentChildrenPickerSelected,
                                whenEmpty: 'Children',
                                onChanged: (List<String> e) =>
                                    _parentChildrenPickerSelected = e)
                          ]),
                        // Laude Point Text Field if [_roleValue] is equal to Student.
                        if (_roleValue == Roles.student.toName)
                          Column(children: [
                            SizedBox.square(dimension: 5.w),
                            TextField(
                                controller: _laudePointsController,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.numbers),
                                    labelText: 'Laude Points'),
                                keyboardType: TextInputType.number),
                          ]),
                      ],
                    ),
                  ),
                ),
                SizedBox.square(dimension: 5.w),
                // Create user button which calls [_createUser()].
                GFButton(
                    onPressed: () => _createUser(),
                    text: 'Create User',
                    icon:
                        const Icon(Icons.person_add_alt_1, color: Colors.white),
                    color: ColorUtil.red)
              ]),
        ));
  }

  /// Populates the [_parentChildrenPickerDisplay] with data from the user's collection.
  void _setParentChildrenPickerDisplay() async {
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection(Collections.users.toPath);
    QuerySnapshot query = await userCollection
        .where("role", isEqualTo: Roles.student.toName)
        .get();
    for (var doc in query.docs) {
      UserModel userModel =
          UserService().getUserFromJson(doc.data() as Map<String, dynamic>);
      _parentChildrenPickerDisplay.addAll({userModel.fullName: userModel.id});
    }
  }
}
