import 'dart:convert';

import 'package:clicili_dark/api/post.dart';
import 'package:clicili_dark/pkg/chewie/chewie.dart';
import 'package:clicili_dark/utils/reg_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

//https://stackoverflow.com/questions/52431109/flutter-video-player-fullscreen
class PlayerPage extends StatefulWidget {
  final int id;

  PlayerPage({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerPageState();
  }
}

//https://vt1.doubanio.com/201902111139/0c06a85c600b915d8c9cbdbbaf06ba9f/view/movie/M/302420330.mp4
class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  TabController _tabController;

  bool isLoading = true;
  Map detail;
  List videoList = [];
  Map videoSrc = {};
  int currPlayIndex = 0;

  Future<String> getVideoSrc(String _src) async {
    if (videoSrc[currPlayIndex] == null) {
      final _videoSrc = (await getPlayUrl(_src)).data['url'];
      videoSrc[currPlayIndex] = _videoSrc;
    }
    return videoSrc[currPlayIndex];
  }

  getDetail() async {
    final res = jsonDecode((await getPostDetail(widget.id)).data)['result'];
    detail = res;
    isLoading = false;
    setState(() {});

    final videoRes = jsonDecode((await getVideoList(widget.id)).data)['videos'];
    videoList = videoRes ?? [];

    if (mounted) {
      setState(() {});
      await initPlayer();
    }
  }

  initPlayer() async {
    if (videoList.length < 1) return;

    final String src = await getVideoSrc(videoList[currPlayIndex]['content']);

    debugPrint('start playing $currPlayIndex $src');

    _videoPlayerController = VideoPlayerController.network(src);
    _videoPlayerController.addListener(autoNextLis);

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      allowedScreenSleep: false,
      allowFullScreen: true,
      videoTitle: Text(
        videoList[currPlayIndex]['title'],
        style:
            Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      fontColor: Colors.white,
      allowMuting: false,
    );
    setState(() {});
  }

  autoNextLis() {
    if (!mounted) {
      _chewieController?.dispose();
      _videoPlayerController?.removeListener(autoNextLis);
      _videoPlayerController?.dispose();
      return;
    }

    int total = _videoPlayerController.value.duration?.inMilliseconds;
    final int pos = _videoPlayerController.value.position?.inMilliseconds ?? 0;

    if (total == null) total = 1;
    if (total - pos <= 0) {
      _videoPlayerController.removeListener(autoNextLis);
      if (currPlayIndex + 1 < videoList.length) toggleVideo(currPlayIndex + 1);
    }
  }

  toggleVideo(int i) async {
    if (i == currPlayIndex ||
        i > videoList.length - 1 ||
        (!_videoPlayerController.value.initialized &&
            !_videoPlayerController.value.hasError)) return;
    await _videoPlayerController.pause();
    currPlayIndex = i;
    await initPlayer();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Wakelock.enable();
    getDetail();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: null,
      statusBarColor: null,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(autoNextLis);
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
        body: SafeArea(
      top: false,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).padding.top,
          ),
          _chewieController != null
              ? Chewie(controller: _chewieController)
              : AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: Center(
                        child: Text(
                      'loading ···',
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: TabBar(
              tabs: <Widget>[Tab(text: '简介'), Tab(text: '评论')],
              controller: _tabController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding:
                  EdgeInsets.symmetric(horizontal: 25, vertical: 0),
              labelColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[buildProfile(), buildComments()],
            ),
          )
        ],
      ),
    ));
  }

  Widget buildProfile() {
    final caption = Theme.of(context).textTheme.caption;
    return Container(
        child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            children: <Widget>[
          Text(detail['title']),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text('gv ${widget.id}  ', style: caption),
              Text(detail['time'], style: caption),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              ClipOval(
                child: Image.network(
                  getAvatar(avatar: detail['uqq']),
                  width: 50,
                  height: 50,
                ),
              ),
              SizedBox(width: 15),
              Text(detail['uname'], style: caption),
            ],
          ),
          SizedBox(height: 25),
          Column(
              children: List.generate(videoList.length, (int i) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  splashColor: Color.fromRGBO(148, 108, 230, 0.6),
                  highlightColor: Color.fromRGBO(148, 108, 230, 0.4),
                  onTap: () {
                    toggleVideo(i);
                  },
                  child: Container(
                    color: i == currPlayIndex
                        ? Color.fromRGBO(148, 108, 230, 0.5)
                        : Color.fromRGBO(148, 108, 230, 0.2),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '     ${videoList[i]['oid']}      ',
                            style: TextStyle(
                                color: Color.fromRGBO(148, 108, 230, 1)),
                          ),
                          Text(
                            '${videoList[i]['title']}',
                            style: TextStyle(
                                color: Color.fromRGBO(148, 108, 230, 1)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                  )),
            );
          })),
        ]));
  }

  Widget buildComments() {
    return Center(child: Text('根据法律法规, 禁止访问 (○｀ 3′○)'));
  }
}
