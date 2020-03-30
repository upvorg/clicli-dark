import 'dart:convert';

import 'package:package_info/package_info.dart';
import 'dart:math' show max;
import 'package:clicli_dark/api/post.dart';

class VersionManager {
  static Future<PackageInfo> getAppVersion() async {
    return await PackageInfo.fromPlatform();
  }

  static int compare(String v1, String v2) {
    if (v1 == v2) return 0;

    List<String> v1Arr = v1.split('.');
    List<String> v2Arr = v2.split('.');
    int i = 0;
    int diff = 0;
    int v1l = v1Arr.length;
    int v2l = v2Arr.length;
    int maxLen = max(v1Arr.length, v2Arr.length);

    if (v1l < maxLen) v1Arr.addAll(List.generate(maxLen - v1l, (i) => '0'));
    if (v2l < maxLen) v2Arr.addAll(List.generate(maxLen - v2l, (i) => '0'));

    while (i < maxLen &&
        (diff = int.parse(v1Arr[i]) - int.parse(v2Arr[i])) == 0) ++i;

    if (diff > 0)
      return 1;
    else if (diff < 0)
      return -1;
    else
      return 0;
  }

  static Future<int> checkUpdate() async {
    final appInfo = jsonDecode((await checkAppUpdateApi()).data);
    final localAppInfo = (await getAppVersion());
    final int major = compare(
        appInfo[0]['apkData']['versionName'].toString(), localAppInfo.version);

    if (major > 0 || major < 0) {
      return major;
    } else if (major == 0) {
      return appInfo[0]['apkData']['versionCode'] -
          int.parse(localAppInfo.buildNumber);
    }

    return 0;
  }
}
