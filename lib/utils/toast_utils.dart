import 'package:flutter/material.dart';
import 'package:clicli_dark/instance.dart';

void showSnackBar(String text, {Color color}) {
  Instances.scaffoldState.showSnackBar(
    SnackBar(
      backgroundColor: Instances.currentThemeColor.withOpacity(0.8),
      content: Text(
        text,
        style: TextStyle(color: color),
      ),
    ),
  );
}

void showErrorSnackBar(String text) {
  Instances.scaffoldState
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
}

void cancelSnackBar() {
  Scaffold.of(Instances.currentContext).hideCurrentSnackBar();
}
