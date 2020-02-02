import 'package:clicli_dark/utils/dio_utils.dart';
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

Future<Response> getPlayUrl(String url) {
  return NetUtils.get('https://jx.clicli.us/jx?url=$url');
}

getSearch(String key) {
  return NetUtils.get('https://api.clicli.us/search/posts?key=$key');
}

getRank() {
  return NetUtils.get('https://api.clicli.us/rank');
}
