import 'package:flutter/material.dart';
import 'package:clicli_dark/instance.dart';

const Duration _snackBarDisplayDuration = Duration(milliseconds: 1000);

void showSnackBar(String text,
    {Color color, Duration duration = _snackBarDisplayDuration}) {
  Instances.scaffoldState.showSnackBar(
    SnackBar(
      duration: duration,
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
        duration: _snackBarDisplayDuration,
        backgroundColor: Colors.red,
        content: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
}

void cancelSnackBar() {
  Instances.scaffoldState.hideCurrentSnackBar();
}
