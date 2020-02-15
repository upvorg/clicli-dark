import 'package:flutter/material.dart';
import 'package:clicli_dark/instance.dart';

const Duration _snackBarDisplayDuration = Duration(milliseconds: 1000);

void showSnackBar(BuildContext ctx, String text,
    {Color color, Duration duration = _snackBarDisplayDuration}) {
  Scaffold.of(ctx).hideCurrentSnackBar();
  Scaffold.of(ctx).showSnackBar(
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

void showErrorSnackBar(BuildContext ctx, String text) {
  Scaffold.of(ctx).hideCurrentSnackBar();
  Scaffold.of(ctx).showSnackBar(
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

void cancelSnackBar(BuildContext ctx) {
  Scaffold.of(ctx).hideCurrentSnackBar();
}
