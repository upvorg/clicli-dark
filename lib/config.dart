import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Config {
  static Future<String> downloadPath() async {
    return (await getExternalStorageDirectory()).path;
  }

  static const Map<int, Color> color = {
    50: Color.fromRGBO(148, 108, 230, .1),
    100: Color.fromRGBO(148, 108, 230, .2),
    200: Color.fromRGBO(148, 108, 230, .3),
    300: Color.fromRGBO(148, 108, 230, .4),
    400: Color.fromRGBO(148, 108, 230, .5),
    500: Color.fromRGBO(148, 108, 230, .6),
    600: Color.fromRGBO(148, 108, 230, .7),
    700: Color.fromRGBO(148, 108, 230, .8),
    800: Color.fromRGBO(148, 108, 230, .9),
    900: Color.fromRGBO(148, 108, 230, 1),
  };

  static const MaterialColor colorCustom = MaterialColor(0xff946ce6, color);
}
