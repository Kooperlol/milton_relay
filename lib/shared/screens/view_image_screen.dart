import 'dart:io';

import 'package:flutter/material.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';

class ViewImageScreen extends StatelessWidget {
  final File image;
  const ViewImageScreen({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(image.path.split('/').last),
      body: Image.file(image,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center),
    );
  }
}
