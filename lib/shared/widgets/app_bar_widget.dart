import 'package:flutter/material.dart';

AppBar getAppBar() {
  return AppBar(
    backgroundColor: const Color.fromRGBO(159, 48, 47, 1),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/miltonrelay-transparent.png',
          height: 59,
          width: 91,
        ),
        const SizedBox.square(dimension: 20),
        const Text(
          'Milton Relay',
          style: TextStyle(fontFamily: 'Lato', fontSize: 36),
        ),
      ],
    ),
  );
}
