import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milton_relay/parent/models/parent.dart';
import 'package:milton_relay/parent/services/parent_service.dart';
import 'package:milton_relay/shared/models/roles.dart';
import 'package:milton_relay/shared/models/user.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/utils/display_util.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/shared/widgets/text_field_widget.dart';
import 'package:milton_relay/student/models/student.dart';
import 'package:milton_relay/student/services/student_service.dart';
import 'package:multiselect/multiselect.dart';

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
  final ImagePicker _picker = ImagePicker();
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

  void pickAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() => _image = imageTemp);
  }

  void createUser() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        await _image?.exists() == false) {
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    List<String> name = _nameController.text.split(" ");
    if (name.length != 2) {
      showSnackBar(context, "Invalid name!");
      return;
    }

    if (_passwordController.text.length < 6) {
      showSnackBar(context, "Your password must be 6 characters!");
      return;
    }

    if (_laudePointsController.text.isNotEmpty &&
        (!isNumeric(_laudePointsController.text) ||
            !isNumeric(_absencesController.text))) {
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
          _parentChildrenPickerSelected
              .map((e) => print(_parentChildrenPickerDisplay[e]));
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

    setState(() {
      _emailController.clear();
      _nameController.clear();
      _laudePointsController.clear();
      _absencesController.clear();
      _parentChildrenPickerSelected = [];
      _passwordController.clear();
      _roleValue = Roles.student.toName;
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Create a User',
                    style: TextStyle(fontFamily: 'lato', fontSize: 25)),
                const SizedBox.square(dimension: 30),
                TextFieldInput(
                    textEditingController: _nameController,
                    hintText: 'Full Name',
                    textInputType: TextInputType.name),
                const SizedBox.square(dimension: 10),
                TextFieldInput(
                    textEditingController: _emailController,
                    hintText: 'Email',
                    textInputType: TextInputType.emailAddress),
                const SizedBox.square(dimension: 10),
                TextFieldInput(
                  textEditingController: _passwordController,
                  hintText: 'Password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                const SizedBox.square(dimension: 10),
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
                const SizedBox.square(dimension: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: _image == null
                          ? Image.asset("assets/default_avatar.jpg").image
                          : Image.file(_image!).image,
                    ),
                    const SizedBox.square(dimension: 10),
                    DropShadow(
                      blurRadius: 5,
                      opacity: 0.5,
                      child: InkWell(
                        onTap: () => pickAvatar(),
                        customBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Container(
                            width: 150,
                            alignment: Alignment.center,
                            color: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_photo_alternate_rounded,
                                      color: Colors.white),
                                  SizedBox.square(dimension: 5),
                                  Text('Upload Avatar',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: 'Lato'))
                                ])),
                      ),
                    ),
                  ],
                ),
                if (_roleValue == Roles.parent.toName)
                  Column(children: [
                    const SizedBox.square(dimension: 10),
                    DropDownMultiSelect(
                        options: _parentChildrenPickerDisplay.keys.toList(),
                        selectedValues: _parentChildrenPickerSelected,
                        whenEmpty: 'Children',
                        onChanged: (List<String> e) =>
                            _parentChildrenPickerSelected = e)
                  ]),
                if (_roleValue == Roles.student.toName)
                  Column(children: [
                    const SizedBox.square(dimension: 10),
                    TextFieldInput(
                        textEditingController: _absencesController,
                        hintText: 'Absences',
                        textInputType: TextInputType.number),
                    const SizedBox.square(dimension: 10),
                    TextFieldInput(
                        textEditingController: _laudePointsController,
                        hintText: 'Laude Points',
                        textInputType: TextInputType.number),
                  ]),
                const SizedBox.square(dimension: 30),
                DropShadow(
                  blurRadius: 5,
                  opacity: 0.5,
                  child: InkWell(
                    onTap: () => createUser(),
                    customBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                        width: 150,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        alignment: Alignment.center,
                        color: ColorUtil.red,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: const Text('Add User',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Lato'))),
                  ),
                )
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
