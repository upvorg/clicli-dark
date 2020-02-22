import 'dart:async';

import 'package:clicli_dark/utils/toast_utils.dart';
import 'package:dio/dio.dart';
//import 'package:flutter/foundation.dart';

class NetUtils {
  static final Dio dio = Dio();

  static Future<void> initConfig() async {
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioError e) async {
        if (e?.response?.statusCode == 401) {}
        if (e?.type == DioErrorType.CONNECT_TIMEOUT ||
            e?.type == DioErrorType.RECEIVE_TIMEOUT ||
            e?.type == DioErrorType.SEND_TIMEOUT) {
          showErrorSnackBar('NETWORK TIMEOUT, TRY AGAIN LATER.');
        }
        return e;
      },
    ));
  }

  static Future<Response<T>> get<T>(String url, {data}) async =>
      await dio.get<T>(
        url,
        queryParameters: data,
      );

  static Future<Response> getWithHeaderSet(String url, {data, headers}) async =>
      await dio.get(
        url,
        queryParameters: data,
        options: Options(),
      );

  static Future<Response> post(String url, {data}) async =>
      await dio.post(url, data: data);
}
