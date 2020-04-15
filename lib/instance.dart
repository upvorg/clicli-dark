import 'package:clicli_dark/config.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static JPush jp = JPush();

  static init() async {
    Instances.jp.setup(appKey: Config.JPushKey, channel: 'developer-default');
    sp = await SharedPreferences.getInstance();
  }
}

class ThemeManager {
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        splashFactory: const NoSplashFactory(),
        primarySwatch: Config.lightColor,
      );

  static bool amoledDark = true;

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        splashFactory: const NoSplashFactory(),
        primarySwatch: Config.darkColor,
        primaryColor: Color.fromRGBO(223, 246, 252, 1),
        cardColor: Colors.black,
        canvasColor: Colors.black87,
//        brightness: Brightness.dark,
//        primaryColor: amoledDark ? Colors.black : Colors.grey[900],
//        primaryColorBrightness: Brightness.dark,
//        primaryColorLight: amoledDark ? Colors.black : Colors.grey[900],
//        primaryColorDark: amoledDark ? Colors.black : Colors.grey[900],
//        accentColor: Color.fromRGBO(223, 246, 252, .1),
//        accentColorBrightness: Brightness.dark,
//        canvasColor: amoledDark ? Color(0xFF111111) : Colors.grey[850],
//        scaffoldBackgroundColor: amoledDark ? Colors.black : Colors.grey[900],
//        bottomAppBarColor: amoledDark ? Colors.black : Colors.grey[900],
//        cardColor: amoledDark ? Colors.black : Colors.grey[900],
//        highlightColor: Colors.transparent,
//        splashFactory: const NoSplashFactory(),
//        toggleableActiveColor: Color.fromRGBO(223, 246, 252, 1),
//        cursorColor: Color.fromRGBO(223, 246, 252, 1),
//        textSelectionColor: Color.fromRGBO(223, 246, 252, 1).withAlpha(100),
//        textSelectionHandleColor: Color.fromRGBO(223, 246, 252, 1),
//        indicatorColor: Color.fromRGBO(223, 246, 252, 1),
//        appBarTheme: AppBarTheme(brightness: Brightness.dark, elevation: 0),
//        iconTheme: IconThemeData(color: Colors.grey[350]),
//        primaryIconTheme: IconThemeData(color: Colors.grey[350]),
//        tabBarTheme: TabBarTheme(
//          indicatorSize: TabBarIndicatorSize.tab,
//          labelColor: Colors.grey[200],
//          unselectedLabelColor: Colors.grey[200],
//        ),
//        textTheme: TextTheme(
//          title: TextStyle(color: Colors.grey[350]),
//          body1: TextStyle(color: Colors.grey[350]),
//          body2: TextStyle(color: Colors.grey[500]),
//          button: TextStyle(color: Colors.grey[350]),
//          caption: TextStyle(color: Colors.grey[500]),
//          subhead: TextStyle(color: Colors.grey[500]),
//          display4: TextStyle(color: Colors.grey[500]),
//          display3: TextStyle(color: Colors.grey[500]),
//          display2: TextStyle(color: Colors.grey[500]),
//          display1: TextStyle(color: Colors.grey[500]),
//          headline: TextStyle(color: Colors.grey[350]),
//          overline: TextStyle(color: Colors.grey[350]),
//        ),
//        buttonColor: Color.fromRGBO(223, 246, 252, 1),
      );

  static bool isDark() {
    final f = Instances.sp.getBool('isDarkTheme');
    return f == null ? false : f;
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

class NoSplashFactory extends InteractiveInkFeatureFactory {
  const NoSplashFactory();

  @override
  InteractiveInkFeature create({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required Offset position,
    @required Color color,
    @required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    VoidCallback onRemoved,
  }) {
    return NoSplash(
      controller: controller,
      referenceBox: referenceBox,
      color: color,
      onRemoved: onRemoved,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    Color color,
    VoidCallback onRemoved,
  })  : assert(controller != null),
        assert(referenceBox != null),
        super(
            controller: controller,
            referenceBox: referenceBox,
            onRemoved: onRemoved) {
    controller.addInkFeature(this);
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}

class TriggerLogin {}

class ChangeTheme {
  ChangeTheme(this.val);

  final bool val;
}
