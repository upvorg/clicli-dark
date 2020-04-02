import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Config {
  static Future<String> downloadPath() async {
    return (await getExternalStorageDirectory()).path;
  }

  static const Map<int, Color> _lightColor = {
    50: Color.fromRGBO(223, 246, 252, .1),
    100: Color.fromRGBO(203, 231, 250, 1),
    200: Color.fromRGBO(183, 210, 247, 1),
    300: Color.fromRGBO(163, 182, 244, 1),
    400: Color.fromRGBO(144, 149, 240, 1),
    500: Color.fromRGBO(141, 126, 235, 1),
    600: Color.fromRGBO(148, 108, 230, 1),
    700: Color.fromRGBO(152, 93, 203, 1),
    800: Color.fromRGBO(152, 78, 176, 1),
    900: Color.fromRGBO(145, 64, 148, 1),
  };

  static const Map<int, Color> _darkColor = {};

  static const MaterialColor lightColor =
      MaterialColor(0xff946ce6, _lightColor);

  static const MaterialColor darkColor = MaterialColor(0xff946ce6, _darkColor);
}
