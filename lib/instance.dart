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
  static bool _isDark;
  static const bool amoledDark = true;
  static const currentColor = Color.fromRGBO(223, 246, 252, .9);

  static bool isDark() {
    _isDark = Instances.sp.getBool('isDarkTheme');
    return _isDark == null ? false : _isDark;
  }

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        splashFactory: const NoSplashFactory(),
        primarySwatch: Config.lightColor,
        appBarTheme: AppBarTheme(brightness: Brightness.light, elevation: 0),
        bottomAppBarTheme: BottomAppBarTheme(elevation: 0.0),
        primaryColor: Colors.white,
        accentColor: Color.fromRGBO(141, 126, 235, 1),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        splashFactory: const NoSplashFactory(),
        primaryColor: amoledDark ? Colors.black : Colors.grey[900],
        primaryColorBrightness: Brightness.dark,
        primaryColorLight: amoledDark ? Colors.black : Colors.grey[900],
        primaryColorDark: amoledDark ? Colors.black : Colors.grey[900],
        accentColor: currentColor,
        accentColorBrightness: Brightness.dark,
        canvasColor: amoledDark ? Color(0xFF111111) : Colors.grey[850],
        scaffoldBackgroundColor: amoledDark ? Colors.black : Colors.grey[900],
        bottomAppBarColor: amoledDark ? Colors.black : Colors.grey[900],
        cardColor: amoledDark ? Colors.black : Colors.grey[900],
        highlightColor: Colors.transparent,
        toggleableActiveColor: currentColor,
        cursorColor: currentColor,
        textSelectionColor: currentColor.withAlpha(100),
        textSelectionHandleColor: currentColor,
        indicatorColor: currentColor,
        appBarTheme: AppBarTheme(brightness: Brightness.dark, elevation: 0),
        iconTheme: IconThemeData(color: Colors.grey[350]),
        primaryIconTheme: IconThemeData(color: Colors.grey[350]),
        tabBarTheme: TabBarTheme(
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.grey[200],
          unselectedLabelColor: Colors.grey[200],
        ),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.grey[350]),
          bodyText2: TextStyle(color: Colors.grey[350]),
          bodyText1: TextStyle(color: Colors.grey[500]),
          button: TextStyle(color: Colors.grey[350]),
          caption: TextStyle(color: Colors.grey[500]),
          subtitle1: TextStyle(color: Colors.grey[500]),
          headline1: TextStyle(color: Colors.grey[500]),
          headline2: TextStyle(color: Colors.grey[500]),
          headline3: TextStyle(color: Colors.grey[500]),
          headline4: TextStyle(color: Colors.grey[500]),
          headline5: TextStyle(color: Colors.grey[350]),
          overline: TextStyle(color: Colors.grey[350]),
        ),
        buttonColor: currentColor,
      );
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
