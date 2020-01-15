import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

String getSuo(String content) {
  final m = RegExp('suo(.+?)\\)')
          .firstMatch(content ?? 'xxxxxxxxxxxxxxxxx')
          ?.group(1) ??
      '';
  String src;
  if (m.length > 0) {
    src = m.substring(2);
    if (m.substring(2)[0] == ' ') {
      src = src.substring(1);
    }
    return Uri.decodeComponent(src);
  }
  return 'https://wx4.sinaimg.cn/mw690/0060lm7Tly1fvmtrka9p5j30b40b43yo.jpg';
}

getAvatar({avatar = ''}) {
  if (RegExp('^[0-9]+\$').hasMatch(avatar)) {
    return 'https://q1.qlogo.cn/g?b=qq&nk=$avatar&s=640';
  } else {
    final hash = generateMd5(avatar);
    return 'https: //cdn.v2ex.com/gravatar/$hash?s=100&d=retro';
  }
}

String generateMd5(String data) {
  var content = new Utf8Encoder().convert(data);
  var digest = md5.convert(content);
  return hex.encode(digest.bytes);
}
