import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget orangeAppBar(String title) {
  return AppBar(
    title: const Align(
      alignment: Alignment.centerLeft,
      child: Image(
        image: AssetImage(
          'assets/Images/phoenix_logo.png',
        ),
        height: 40,
      ),
    ),
    backgroundColor: Colors.orange[600],
  );
}
