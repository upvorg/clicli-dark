import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:clicili_dark/api/post.dart';
import 'package:clicili_dark/utils/reg_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

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
  int currPlayIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    getDetail();
    super.initState();
  }

  getDetail() async {
    final videoRes = jsonDecode((await getVideoList(widget.id)).data)['videos'];
    final res = jsonDecode((await getPostDetail(widget.id)).data)['result'];

    videoList = videoRes;
    detail = res;
    isLoading = false;

    print(res['uqq']);
    setState(() {});
    initPlayer();
  }

  initPlayer() {
    final src = videoList[currPlayIndex]['content'];

    //https://vt1.doubanio.com/201902111139/0c06a85c600b915d8c9cbdbbaf06ba9f/view/movie/M/302420330.mp4
    _videoPlayerController = VideoPlayerController.network(src);

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
      aspectRatio: 16 / 9,
      autoInitialize: true,
      autoPlay: true,
      looping: false,
    );

    _chewieController.addListener(() {
      if (!_chewieController.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
  }

  toggleVideo(int i) {
    if (i == currPlayIndex) return;
    if (_videoPlayerController != null) {
      _videoPlayerController.pause();
      _videoPlayerController.seekTo(Duration(seconds: 0));
    }
    if (_chewieController != null) {
      _chewieController.dispose();
    }

    currPlayIndex = i;
    setState(() {});
    initPlayer();
  }

  disposeV() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _chewieController = _videoPlayerController = null;
  }

  @override
  void dispose() {
    super.dispose();
    disposeV();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Theme(
                  data: ThemeData(
                    dialogBackgroundColor: Colors.white.withOpacity(0.2),
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
    );
  }

  Widget buildProfile() {
    return Container(
        child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            children: <Widget>[
          Text(
            detail['title'],
          ),
          Row(
            children: <Widget>[
              Text(
                '${widget.id}  ',
                style: Theme.of(context).textTheme.caption,
              ),
              Text(
                detail['time'],
                style: Theme.of(context).textTheme.caption,
              ),
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
              Text(
                detail['uname'],
                style: Theme.of(context).textTheme.caption,
              ),
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
                    color: Color.fromRGBO(148, 108, 230, 0.2),
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
    return Center(child: Text('敬请期待'));
  }
}
