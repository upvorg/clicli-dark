import 'package:path_provider/path_provider.dart';

class Config {
  static Future<String> downloadPath() async {
    return (await getExternalStorageDirectory()).path;
  }
}
