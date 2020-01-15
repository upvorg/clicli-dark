import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showLongToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_LONG,
  );
}

void showShortToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
  );
}

void showCenterShortToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
  );
}

void showErrorShortToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    backgroundColor: Color(0xFFE5322D),
    toastLength: Toast.LENGTH_SHORT,
  );
}

void showCenterErrorShortToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    backgroundColor: Color(0xFFE5322D),
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
  );
}

void showTopShortToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
  );
}

void cancelToast() {
  Fluttertoast.cancel();
}
