import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/parent/models/parent.dart';
import 'package:milton_relay/parent/services/parent_service.dart';
import 'package:milton_relay/shared/utils/roles.dart';
import 'package:milton_relay/shared/models/user_model.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/utils/display_util.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/shared/widgets/text_field_widget.dart';
import 'package:milton_relay/student/models/student.dart';
import 'package:milton_relay/student/services/student_service.dart';
import 'package:multiselect/multiselect.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/utils/collections.dart';
import '../../shared/utils/color_util.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _nameController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController(),
      _absencesController = TextEditingController(),
      _laudePointsController = TextEditingController();
  List<String> _parentChildrenPickerSelected = [];
  final Map<String, String> _parentChildrenPickerDisplay = {};
  String _roleValue = Roles.student.toName;
  File? _image;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _absencesController.dispose();
    _laudePointsController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setParentChildrenPickerDisplay();
  }

  void createUser() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        await _image?.exists() == false) {
      if (!mounted) return;
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    List<String> name = _nameController.text.split(" ");
    if (name.length != 2) {
      if (!mounted) return;
      showSnackBar(context, "Invalid name!");
      return;
    }

    if (_passwordController.text.length < 6) {
      if (!mounted) return;
      showSnackBar(context, "Your password must be 6 characters!");
      return;
    }

    if (_laudePointsController.text.isNotEmpty &&
        (!isNumeric(_laudePointsController.text) ||
            !isNumeric(_absencesController.text))) {
      if (!mounted) return;
      showSnackBar(context, "The value must be numeric!");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("avatars/${userCredential.user!.uid}");
      TaskSnapshot uploadTask = await storageRef.putFile(_image!);

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
              roleFromString(_roleValue)));
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
              int.parse(_absencesController.text),
              double.parse(_laudePointsController.text)));
          break;
        case Roles.admin:
          return;
      }
      users.doc(userCredential.user!.uid).set(data);
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to create a new user: ${error.toString()}");
    }

    if (!mounted) return;
    showSnackBar(context, "Created user!");

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar('Create a User'),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFieldInput(
                    textEditingController: _nameController,
                    hintText: 'Full Name',
                    textInputType: TextInputType.name),
                SizedBox.square(dimension: 2.w),
                TextFieldInput(
                    textEditingController: _emailController,
                    hintText: 'Email',
                    textInputType: TextInputType.emailAddress),
                SizedBox.square(dimension: 2.w),
                TextFieldInput(
                  textEditingController: _passwordController,
                  hintText: 'Password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                SizedBox.square(dimension: 2.w),
                DropdownButton<String>(
                  value: _roleValue,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  onChanged: (String? value) {
                    setState(() => {_roleValue = value!});
                  },
                  items: Roles.values
                      .where((element) => element != Roles.admin)
                      .map((e) => e.toName)
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox.square(dimension: 2.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 7.5.w,
                      backgroundImage: _image == null
                          ? Image.asset("assets/default-user-avatar.jpg").image
                          : Image.file(_image!).image,
                    ),
                    SizedBox.square(dimension: 2.w),
                    createButton('Upload Avatar', 30.w, () async {
                      File? image = await pickImage();
                      setState(() => _image = image);
                    },
                        color: ColorUtil.darkGray,
                        icon: Icons.add_photo_alternate)
                  ],
                ),
                if (_roleValue == Roles.parent.toName)
                  Column(children: [
                    SizedBox.square(dimension: 2.w),
                    DropDownMultiSelect(
                        options: _parentChildrenPickerDisplay.keys.toList(),
                        selectedValues: _parentChildrenPickerSelected,
                        whenEmpty: 'Children',
                        onChanged: (List<String> e) =>
                            _parentChildrenPickerSelected = e)
                  ]),
                if (_roleValue == Roles.student.toName)
                  Column(children: [
                    SizedBox.square(dimension: 2.w),
                    TextFieldInput(
                        textEditingController: _absencesController,
                        hintText: 'Absences',
                        textInputType: TextInputType.number),
                    SizedBox.square(dimension: 2.w),
                    TextFieldInput(
                        textEditingController: _laudePointsController,
                        hintText: 'Laude Points',
                        textInputType: TextInputType.number),
                  ]),
                SizedBox.square(dimension: 4.w),
                createButton('Add User', 30.w, () => createUser(),
                    icon: Icons.person_add_alt_1)
              ]),
        ));
  }

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
