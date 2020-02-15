import 'package:flutter/material.dart';

class Instances {
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  static ScaffoldState get scaffoldState => Instances.scaffoldKey.currentState;

  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get navigatorState =>
      Instances.navigatorKey.currentState;

  static BuildContext get currentContext => navigatorState.overlay.context;

  static ThemeData get currentTheme => Theme.of(navigatorState.context);

  static Color get currentThemeColor => currentTheme.primaryColor;
}
