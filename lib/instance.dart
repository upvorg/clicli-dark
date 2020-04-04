import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_bus/event_bus.dart';

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

  static SharedPreferences sp;

  static EventBus eventBus = EventBus();

  static init() async {
    sp = await SharedPreferences.getInstance();
  }
}

class ThemeManager {
  static bool isDark() {
    return Instances.sp.getBool('isDarkTheme');
  }

  static void toggleAppbarThemeByLocal() {
    toggleAppbarTheme(isDark());
  }

  static void toggleAppbarTheme(bool isDark) {
    isDark ? toggleDarkAppBarTheme() : toggleLightAppBarTheme();
  }

  static void toggleDarkAppBarTheme() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
    ));
  }

  static toggleLightAppBarTheme() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
    ));
  }
}

class TriggerLogin {}

class ChangeTheme {
  ChangeTheme(this.val);
  final bool val;
}
