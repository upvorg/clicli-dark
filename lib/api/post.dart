import 'package:clicili_dark/utils/dio_utils.dart';
import 'package:dio/dio.dart';

getPost(
  type,
  String tag,
  int page,
  int pageSize, {
  status = 'public',
  uid = '',
}) {
  return NetUtils.get(
      'https://api.clicli.us/posts?status=$status&sort=$type&tag=$tag&uid=$uid&page=$page&pageSize=$pageSize');
}

Future<Response<T>> getPostDetail<T>(int pid) {
  return NetUtils.get('https://api.clicli.us/post/$pid');
}

getVideoList(int pid) {
  return NetUtils.get(
      'https://api.clicli.us/videos?pid=$pid&page=1&pageSize=150');
}
