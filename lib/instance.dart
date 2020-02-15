import 'package:flutter/material.dart';

class Instances {
  static final homeStackscaffoldKey = GlobalKey<ScaffoldState>();

  static ScaffoldState get scaffoldState =>
      Instances.homeStackscaffoldKey.currentState;

  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get navigatorState =>
      Instances.navigatorKey.currentState;

  static BuildContext get currentContext => navigatorState.overlay.context;

  static ThemeData get currentTheme => Theme.of(navigatorState.context);

  static Color get currentThemeColor => currentTheme.primaryColor;
}
