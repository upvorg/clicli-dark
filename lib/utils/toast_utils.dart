import 'package:flutter/material.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';

const int duration = 1;

void showSnackBar(String text) {
  FlutterFlexibleToast.cancel();
  FlutterFlexibleToast.showToast(
    message: text,
    toastLength: Toast.LENGTH_LONG,
    toastGravity: ToastGravity.BOTTOM,
    icon: ICON.INFO,
    radius: 10,
    elevation: 10,
    textColor: Colors.white,
    backgroundColor: Colors.black,
    timeInSeconds: duration,
  );
}

void showErrorSnackBar(String text) {
  FlutterFlexibleToast.cancel();
  FlutterFlexibleToast.showToast(
    message: text,
    toastLength: Toast.LENGTH_LONG,
    toastGravity: ToastGravity.BOTTOM,
    icon: ICON.ERROR,
    radius: 10,
    elevation: 10,
    textColor: Colors.white,
    backgroundColor: Colors.black,
    timeInSeconds: duration,
  );
}

void cancelSnackBar() {
  FlutterFlexibleToast.cancel();
}
