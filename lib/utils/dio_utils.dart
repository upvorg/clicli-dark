import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clicli_dark/utils/toast_utils.dart';

class Response {
  Response(this.data);
  String data;
}

class NetUtils {
  static final HttpClient httpClient = HttpClient();

  static sink() {
    httpClient.close();
  }

  static Future<Response> _send(String methond, String url, {data}) async {
    httpClient.connectionTimeout = Duration(milliseconds: 10000);
    HttpClientResponse response;
    try {
      final HttpClientRequest request =
          await httpClient.openUrl(methond, Uri.parse(url));
      request
        ..followRedirects = false
        ..persistentConnection = true;
      if (data != null) {
        request.headers.set('content-type', 'application/json');
        request.add(utf8.encode((json.encode(data))));
      }
      response = await request.close();
    } catch (e) {
      showErrorSnackBar('网络似乎出了一点问题');
    }

    if (response == null) return Response('');

    final String _text = await response.transform(utf8.decoder).join();
    return Response(_text);
  }

  static Future get(String url, {data}) async {
    return await _send('GET', url, data: data);
  }

  static Future post(String url, {data}) async {
    return await _send('POST', url, data: data);
  }
}
