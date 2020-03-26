import 'package:clicli_dark/utils/dio_utils.dart';

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

getPostDetail<T>(int pid) async {
  return NetUtils.get('https://api.clicli.us/post/$pid');
}

getVideoList(int pid) {
  return NetUtils.get(
      'https://api.clicli.us/videos?pid=$pid&page=1&pageSize=150');
}

getPlayUrl(String url) {
  return NetUtils.get('https://jx.clicli.us/jx?url=$url');
}

getSearch(String key) {
  return NetUtils.get('https://api.clicli.us/search/posts?key=$key');
}

getRank() {
  return NetUtils.get('https://api.clicli.us/rank');
}

getPV(int id) {
  return NetUtils.get('https://jx.clicli.us/get/pv?pid=$id');
}

login(data) {
  return NetUtils.post('https://admin.clicli.me/user/login', data: data);
}

checkAppUpdateApi() {
  return NetUtils.get(
      'https://cdn.jsdelivr.net/gh/cliclitv/app.clicli.me@master/output.json');
}
