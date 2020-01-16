import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

BaseOptions baseOptions = BaseOptions(
//  baseUrl: Constants.BASE_URL,
  headers: {HttpHeaders.acceptHeader: "*"},
  connectTimeout: 10000,
  receiveTimeout: 10000,
  contentType: "accept: application/json",
  responseType: ResponseType.json,
);

class NetUtils {
  static final Dio dio = Dio(baseOptions);
  static final Dio tokenDio = Dio();

  static void initConfig() async {
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioError e) async {
        debugPrint("DioError: ${e.message}");
        if (e?.response?.statusCode == 401) {}
        return e;
      },
    ));

    tokenDio.interceptors.add(InterceptorsWrapper(
      onError: (DioError e) async {
        debugPrint("Token DioError: ${e.message}");
        return e;
      },
    ));
  }

  static Future<Response<T>> get<T>(String url, {data}) async =>
      await dio.get<T>(
        url,
        queryParameters: data,
      );

  static Future<Response> getWithHeaderSet(
    String url, {
    data,
    headers,
  }) async =>
      await dio.get(
        url,
        queryParameters: data,
        options: Options(),
      );

  static Future<Response> post(String url, {data}) async => await dio.post(
        url,
        data: data,
      );
}
