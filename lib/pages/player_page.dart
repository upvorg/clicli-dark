import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:clicili_dark/api/post.dart';
import 'package:clicili_dark/utils/reg_utils.dart';
import 'package:clicili_dark/utils/toast_utils.dart';
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

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  TabController _tabController;

  Map detail;
  List videoList;
  Map videoSrc = {};
  int currPlayIndex = 0;
  bool isLoading = true;
  bool playerLoading = false;
  bool playerLoaded = false;

  Future<String> getVideoSrc(String _src) async {
    if (videoSrc[currPlayIndex] == null) {
      final _videoSrc = (await getPlayUrl(_src)).data['url'];
      videoSrc[currPlayIndex] = _videoSrc;
    }
    return videoSrc[currPlayIndex];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Wakelock.enable();
    getDetail();
  }

  getDetail() async {
    final videoRes = jsonDecode((await getVideoList(widget.id)).data)['videos'];
    final res = jsonDecode((await getPostDetail(widget.id)).data)['result'];

    videoList = videoRes ?? [];
    detail = res;
    isLoading = false;

    setState(() {});
    initPlayer();
  }

  initPlayer() async {
    if (videoList.length < 1) {
      playerLoaded = true;
      return;
    }

    if (playerLoading) return;

    final String src = await getVideoSrc(videoList[currPlayIndex]['content']);
    if (src == null ||
        (src is String && (src.length < 1 || src.endsWith('.m3u8')))) {
      showCenterErrorShortToast('视频地址错误');
      playerLoaded = true;
      return;
    }

    playerLoading = true;

    debugPrint('start playing $currPlayIndex $src');

    //https://vt1.doubanio.com/201902111139/0c06a85c600b915d8c9cbdbbaf06ba9f/view/movie/M/302420330.mp4
    _videoPlayerController = VideoPlayerController.network(src);
    _videoPlayerController.addListener(autoNextLis);

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      allowedScreenSleep: false,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      materialProgressColors: ChewieProgressColors(
        backgroundColor: Colors.purple.withOpacity(0.2),
        playedColor: Colors.purple.withOpacity(0.7),
        bufferedColor: Colors.purple.withOpacity(0.4),
        handleColor: Color.fromRGBO(200, 200, 200, 1.0),
      ),
      aspectRatio: 16 / 9,
//      autoInitialize: true,
//      autoPlay: true,
      looping: false,
    );
    _chewieController.addListener(fullScreenLis);
    await _videoPlayerController.initialize();
    _chewieController.play();

    playerLoaded = true;
    playerLoading = false;
    setState(() {});
  }

  fullScreenLis() {
    if (!_chewieController.isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  autoNextLis() {
    int total = _videoPlayerController.value.duration?.inMilliseconds;
    final int pos = _videoPlayerController.value.position?.inMilliseconds ?? 0;

    if (total == null) total = 1;
    if (total - pos <= 0) {
      _videoPlayerController.removeListener(autoNextLis);
      if (currPlayIndex + 1 < videoList.length) toggleVideo(currPlayIndex + 1);
    }
  }

  toggleVideo(int i) {
    if (i == currPlayIndex || i > videoList.length - 1) return;

//    _videoPlayerController?.pause();
    _chewieController?.pause();
    _chewieController?.seekTo(Duration(seconds: 0));
//    _videoPlayerController?.seekTo(Duration(seconds: 0));

//    _chewieController?.dispose();

    currPlayIndex = i;
    initPlayer();
  }

  disposeControllers() {
    Wakelock.disable();
    _chewieController?.removeListener(fullScreenLis);
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
  }

  @override
  void dispose() {
    disposeControllers();
    _videoPlayerController?.removeListener(autoNextLis);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<bool> _onWillPop() {
    if (isLoading || !playerLoaded) {
      showCenterErrorShortToast('请等待播放器加载完毕');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Theme(
                    data: ThemeData(
                      dialogBackgroundColor: Colors.transparent,
                      primarySwatch: Colors.purple,
                      iconTheme: Theme.of(context)
                          .iconTheme
                          .copyWith(color: Colors.white),
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(color: Colors.white),
                      child: _chewieController != null
                          ? Chewie(
                              controller: _chewieController,
                            )
                          : AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                color: Colors.black,
                                child: Center(
                                  child: const Text(
                                    '加载中···',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ],
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
              ))
            ],
          ),
        ),
      ),
    );
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
