import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:milton_relay/shared/models/post_model.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:uuid/uuid.dart';

import '../models/collections.dart';
import '../routing/routes.dart';
import '../services/post_service.dart';
import '../utils/color_util.dart';
import '../utils/display_util.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController(),
      _descriptionController = TextEditingController();
  final List<File> _images = [];

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Create Post'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
        child: Column(
          children: [
            Card(
              color: ColorUtil.snowWhite,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(children: [
                  TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.title), labelText: 'Title')),
                  SizedBox.square(dimension: 5.w),
                  TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.chat), labelText: 'Caption')),
                  SizedBox.square(dimension: 5.w),
                  GFButton(
                      onPressed: () {
                        if (_images.length >= 5) {
                          showSnackBar(context,
                              'The maximum number of attachments is 5!');
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
                  SizedBox.square(dimension: 5.w),
                  ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Center(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            onPressed: () =>
                                setState(() => _images.removeAt(index)),
                            icon: Icon(Icons.delete, color: ColorUtil.red)),
                        TextButton(
                          child: Text(_images[index].path.split('/').last,
                              style: TextStyle(fontSize: 2.w)),
                          onPressed: () {
                            context.push(Routes.viewImage.toPath,
                                extra: _images[index]);
                          },
                        ),
                      ]));
                    },
                    itemCount: _images.length,
                  )
                ]),
              ),
            ),
            SizedBox.square(dimension: 5.w),
            GFButton(
                onPressed: () => _addPost(),
                icon: Icon(Icons.add_photo_alternate,
                    color: Colors.white, size: 4.w),
                textStyle: TextStyle(fontSize: 4.w),
                size: 8.w,
                padding: EdgeInsets.all(1.w),
                text: 'Add Post',
                color: ColorUtil.red)
          ],
        ),
      ),
    );
  }

  Future<void> _addPost() async {
    if (_descriptionController.text.isEmpty || _titleController.text.isEmpty) {
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    if (_images.isEmpty) {
      showSnackBar(context, "You must upload at least one photo!");
      return;
    }

    if (_descriptionController.text.characters.length > 400) {
      showSnackBar(
          context, "The description can't be greater than 400 characters!");
      return;
    }

    if (_titleController.text.characters.length > 75) {
      showSnackBar(context, "The title can't be greater than 75 characters!");
      return;
    }

    context.loaderOverlay.show();

    var uuid = const Uuid();
    var id = uuid.v1();

    List<String> imageURls = [];
    try {
      for (var image in _images) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child("posts/$id/${image.path.split('/').last}");
        await storageRef.putFile(image);
        imageURls.add(await storageRef.getDownloadURL());
      }

      CollectionReference postsCollection =
          FirebaseFirestore.instance.collection(Collections.posts.toPath);
      PostModel postModel = PostModel(
          id,
          AuthService().getUID(),
          DateTime.now(),
          imageURls,
          _titleController.text,
          _descriptionController.text, []);
      await postsCollection.doc(id).set(PostService().postToJson(postModel));
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to create a post: ${error.toString()}");
    }

    if (!mounted) return;
    showSnackBar(context, "You just posted a photo!");
    context.loaderOverlay.hide();
    context.pop();
  }

  void _addImage() async {
    File? file = await pickImage();
    if (file == null) return;
    setState(() => _images.add(file));
    if (!mounted) return;
    showSnackBar(context, 'You have uploaded an image!');
  }
}
