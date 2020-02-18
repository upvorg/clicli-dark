import 'dart:convert';
import 'dart:io';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/pages/search_page.dart';
import 'package:clicli_dark/pkg/chewie/chewie.dart';
import 'package:clicli_dark/utils/reg_utils.dart';
import 'package:clicli_dark/utils/toast_utils.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:clicli_dark/widgets/common_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:screen/screen.dart';

//https://stackoverflow.com/questions/52431109/flutter-video-player-fullscreen
class PlayerPage extends StatefulWidget with WidgetsBindingObserver {
  final int id;

  PlayerPage({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerPageState();
  }
}

//https://vt1.doubanio.com/201902111139/0c06a85c600b915d8c9cbdbbaf06ba9f/view/movie/M/302420330.mp4
class _PlayerPageState extends State<PlayerPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  TabController _tabController;

  String thumbnail;
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

    thumbnail = getSuo(res['content']);
    detail = res;
    isLoading = false;

    final videoRes = jsonDecode((await getVideoList(widget.id)).data)['videos'];
    videoList = videoRes ?? [];
    if (videoList.length > 0) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ));
    }

    final pv = jsonDecode((await getPV(widget.id)).toString())['pv'];
    detail['pv'] = pv;

    if (mounted) {
      setState(() {});
      if (videoList.length > 0) await initPlayer();
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
      videoTitle: videoList[currPlayIndex]['title'],
      fontColor: Colors.white,
      allowMuting: false,
      enableDLNA: true,
      thumbnail: thumbnail,
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
            !_videoPlayerController.value.hasError &&
            _videoPlayerController != null)) return;
    await _videoPlayerController.pause();
    currPlayIndex = i;
    await initPlayer();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Screen.keepOn(true);
    getDetail();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (_videoPlayerController.value.isPlaying)
          _videoPlayerController.pause();
        break;
      default:
        if (!_videoPlayerController.value.isPlaying)
          _videoPlayerController.play();
        break;
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(autoNextLis);
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
    WidgetsBinding.instance.removeObserver(this);
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
      child: videoList.length > 0
          ? Column(
              children: <Widget>[
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
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        offset: Offset(0, 5),
                        blurRadius: 12,
                        spreadRadius: -10,
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: TabBar(
                    tabs: <Widget>[Tab(text: '剧集'), Tab(text: '简介')],
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
                    children: <Widget>[buildProfile(context), buildComments()],
                  ),
                )
              ],
            )
          : Column(
              children: <Widget>[
                FixedAppBar(
                  title: Text(
                    detail['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.more_horiz),
                      onPressed: () {
                        showSnackBar('这里不可以哦 o(*////▽////*)q');
                      },
                    )
                  ],
                ),
                Expanded(child: buildComments())
              ],
            ),
    ));
  }

  Widget buildProfile(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.caption;
    final List tags = detail['tag'].substring(1).split(' ');
    final time = DateTime.parse(detail['time']);
    final m = time.month < 10 ? '0${time.month}' : time.month;
    final d = time.day < 10 ? '0${time.day}' : time.day;
    return Container(
        child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            children: <Widget>[
          Text(detail['title']),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text('GV${widget.id}  ', style: caption),
              Text(' $m-$d  ', style: caption),
              Icon(
                Icons.whatshot,
                size: 12,
                color: theme.primaryColor,
              ),
              Text('${detail['pv']?.toString() ?? 0} ℃',
                  style: caption.copyWith(color: theme.primaryColor)),
            ],
          ),
          SizedBox(height: 10),
          Row(children: [
            for (int i = 0; i < tags.length; i++)
              if (tags[i].length > 0)
                GestureDetector(
                  onTap: () {
                    if (_videoPlayerController.value.isPlaying)
                      _videoPlayerController.pause();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            TagPage(tags[i] as String)));
                  },
                  onDoubleTap: () {
                    if (_videoPlayerController.value.isPlaying)
                      _videoPlayerController.pause();

                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            TagPage(tags[i] as String)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      tags[i],
                      style: TextStyle(
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                )
          ]),
          // SizedBox(height: 10),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: <Widget>[
          //     // IconButton(
          //     //   icon: Icon(
          //     //     Icons.favorite_border,
          //     //     color: caption.color,
          //     //   ),
          //     // ),
          //   ],
          // ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              ClipOval(
                child: Image.network(
                  getAvatar(avatar: detail['uqq']),
                  width: 40,
                  height: 40,
                ),
              ),
              SizedBox(width: 15),
              Text(detail['uname'], style: caption),
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: caption.color,
                ),
                onPressed: () async {
                  final path = (await getExternalStorageDirectory()).path;
                  final downloadPath = Directory('$path/${detail['title']}');
                  if (!downloadPath.existsSync()) downloadPath.createSync();
                  final fileName =
                      '$currPlayIndex  ${_chewieController.videoTitle}';

                  final tasks = await FlutterDownloader.loadTasks();
                  if (tasks.any((task) => task.filename == fileName)) {
                    showSnackBar('正在下载···');
                    return;
                  }

                  showSnackBar('开始下载···');
                  await FlutterDownloader.enqueue(
                    url: _videoPlayerController.dataSource,
                    savedDir: downloadPath.path,
                    showNotification: true,
                    openFileFromNotification: true,
                    fileName: '$currPlayIndex  ${_chewieController.videoTitle}',
                  );
                },
              )
            ],
          ),
          SizedBox(height: 10),
          buildVideoList()
        ]));
  }

  Widget buildVideoList() {
    final color = Color.fromRGBO(148, 108, 230, 1);
    return Column(
        children: List.generate(videoList.length, (int i) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: InkWell(
            splashColor: color.withOpacity(0.6),
            highlightColor: color.withOpacity(0.4),
            onTap: () {
              toggleVideo(i);
            },
            child: Container(
              color: i == currPlayIndex
                  ? color.withOpacity(0.5)
                  : color.withOpacity(0.2),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: <Widget>[
                  Text(
                    '  ${videoList[i]['oid']}  ',
                    style: TextStyle(color: color),
                  ),
                  Expanded(
                    child: ellipsisText(
                      '${videoList[i]['title']}',
                      style: TextStyle(color: color),
                    ),
                  )
                ],
              ),
            )),
      );
    }));
  }

  Widget buildComments() {
    final i = detail['content'].indexOf('# 播放出错');
    final content =
        i < 0 ? detail['content'] : detail['content'].substring(0, i);
    final meta =
        '''${videoList.length > 0 ? '# ${detail['title']} \r\n ' : ''}> ${detail['uname']}  ${detail['time']}   GV${detail['id']} \r\n#  ''';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: MarkdownBody(
          // selectable: true,
          data: meta + content,
          onTapLink: (url) async {
            showDialog<Null>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('提示'),
                    content: Text('是否使用外部打开该链接？\r\n\r\n $url'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('确定'),
                        onPressed: () async {
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            showErrorSnackBar('打开链接失败');
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          },
          styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
          styleSheet: MarkdownStyleSheet(
            blockquotePadding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            blockquoteDecoration:
                BoxDecoration(border: Border(left: BorderSide(width: 2.0))),
            code: TextStyle(fontFamily: "Source Code Pro"),
            a: TextStyle(color: Theme.of(context).primaryColor),
          )),
    );
  }
}
