import 'dart:async';

import 'package:clicli_dark/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';
import 'package:music_volume/music_volume.dart';

import './chewie_player.dart';
import './chewie_progress_colors.dart';
import './material_progress_bar.dart';
import './utils.dart';

class LinearProgress extends StatelessWidget {
  final double len;
  final IconData icon;

  LinearProgress(this.len, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      width: MediaQuery.of(context).size.width / 4,
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              icon,
              size: 20,
              color: ChewieController.of(context).fontColor,
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: len,
              backgroundColor: Colors.white.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          )
        ],
      ),
    );
  }
}

class MaterialControls extends StatefulWidget {
  const MaterialControls({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls> {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;

  // bool showPop = false;

  final barHeight = 38.0;
  // final marginSize = 5.0;

  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context, _latestValue.errorDescription)
          : Container(
              color: chewieController.backgroundColor,
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: <Widget>[
                  _buildVideoBar(isErr: true),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: chewieController.fontColor,
                          size: 42,
                        ),
                        Text(
                          '播放出错',
                          style: TextStyle(color: chewieController.fontColor),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
    }

    if (_latestValue != null &&
            !_latestValue.isPlaying &&
            _latestValue.duration == null ||
        _latestValue.isBuffering)
      return Column(
        children: [
          Expanded(
              child: Container(
            decoration: chewieController.thumbnail != null
                ? BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(chewieController.thumbnail),
                    ),
                  )
                : null,
            child: const Center(
              child: const CircularProgressIndicator(),
            ),
          ))
        ],
      );

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragDown: _onHorizontalDragDown,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onTap: () => _cancelAndRestartTimer(),
        onDoubleTap: _playPause,
        child: Column(
          children: <Widget>[
            AbsorbPointer(
              child: _buildVideoBar(),
              absorbing: _hideStuff,
            ),
            _buildHitArea(),
            AbsorbPointer(
              child: _buildBottomBar(context),
              absorbing: _hideStuff,
            ),
            // showPop && chewieController.enableDLNA
            //     ? Expanded(child: _buildDlna())
            //     : _buildHitArea(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
    // Volume.dispose();
    if (initBri != null) Screen.setBrightness(initBri);
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  double _startVerticalDragY = 0;
  double _startVerticalDragX = 0;
  double _endVerticalDragY = 0;

  bool showBrightness = false;
  double initBri;
  double brighting = 0.0;

  bool showVolTip = false;
  int initVol;
  double voling = 0.0;
  double volProgress = 0.0;

  void _onVerticalDragDown(DragDownDetails d) {
    _startVerticalDragX = d.localPosition.dx;
    _startVerticalDragY = d.localPosition.dy;
  }

  void _onVerticalDragStart(DragStartDetails d) async {
    if (_startVerticalDragX < MediaQuery.of(context).size.width / 2) {
      initBri = await Screen.brightness;
      showBrightness = true;
    } else {
      initVol = await MusicVolume.currentVolume; /*await Volume.getVol*/
      showVolTip = true;
    }
    setState(() {});
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) async {
    final w = MediaQuery.of(context).size.width;
    _endVerticalDragY = d.localPosition.dy;
    final drag = -(_endVerticalDragY - _startVerticalDragY);
    final totalHor =
        w / chewieController.videoPlayerController.value.aspectRatio -
            2 * barHeight;
    if (_startHorizontalDragX < w / 2) {
      final _ = initBri + (drag / totalHor);
      brighting = _ <= 0 ? 0.0 : _ >= 1 ? 1.0 : _;
      await Screen.setBrightness(brighting);
    } else {
      final int maxVol = await MusicVolume.maxVolume;
      final _ = initVol + drag / totalHor * maxVol;
      voling = _ > maxVol ? maxVol.toDouble() : _ < 0.0 ? 0.0 : _;
      volProgress = voling / maxVol;
      await MusicVolume.changeVolume(_.toInt(), 0);
    }
    setState(() {});
  }

  void _onVerticalDragEnd(DragEndDetails d) async {
    if (_startVerticalDragX < MediaQuery.of(context).size.width / 2) {
      showBrightness = false;
    } else {
      showVolTip = false;
    }
    setState(() {});
  }

  bool showTimeLine = false;
  double _startHorizontalDragX = 0;
  int _horizontalDragTime = 0;
  Duration initPos;

  void _onHorizontalDragDown(DragDownDetails d) async {
    _startHorizontalDragX = d.localPosition.dx;
    initPos = _latestValue.position;
  }

  void _onHorizontalDragStart(DragStartDetails d) async {
    _cancelAndRestartTimer();
    setState(() {
      showTimeLine = true;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) async {
    _cancelAndRestartTimer();
    final w = MediaQuery.of(context).size.width;
    final m = (d.localPosition.dx - _startHorizontalDragX) / w * 90; // 90s
    chewieController
        .seekTo(initPos + Duration(seconds: _horizontalDragTime.toInt()));
    _horizontalDragTime = m.toInt();

    setState(() {});
  }

  void _onHorizontalDragEnd(DragEndDetails d) async {
    _cancelAndRestartTimer();
    showTimeLine = false;
    setState(() {});
    // chewieController.seekTo(
    //     _latestValue.position + Duration(seconds: _horizontalDragTime.toInt()));
  }

  AnimatedOpacity _buildBottomBar(BuildContext context) {
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              chewieController.controllerBackGroundColor.withOpacity(0.5),
              Colors.transparent
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Row(
          children: <Widget>[
            _buildPlayPause(controller),
            chewieController.isLive
                ? Expanded(child: const Text('LIVE'))
                : _buildPosition(),
            if (!chewieController.isLive) _buildProgressBar(),
            if (chewieController.allowMuting) _buildMuteButton(controller),
            if (chewieController.allowFullScreen) _buildExpandButton(),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          height: barHeight,
          margin: EdgeInsets.only(right: 4.0),
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Center(
            child: Icon(
              chewieController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: chewieController.fontColor,
            ),
          ),
        ),
      ),
    );
  }

  AnimatedOpacity _buildVideoBar({bool isErr = false}) {
    return AnimatedOpacity(
      opacity: isErr ? 1.0 : _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              chewieController.controllerBackGroundColor.withOpacity(0.5),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: chewieController.fontColor,
              ),
              onPressed: () {
                Navigator.of(context).canPop() && Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: Text(
                chewieController.videoTitle,
                style: TextStyle(color: chewieController.fontColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: chewieController.fontColor,
              ),
              onPressed: () {
                showSnackBar('coming soon···');
                // showPop = !showPop;
              },
            )
          ],
        ),
      ),
    );
  }

  void _toggleAndRestartTimer() {
    if (_hideStuff) {
      _hideTimer?.cancel();
      _startHideTimer();

      setState(() {
        _hideStuff = false;
      });
    } else {
      setState(() {
        _hideStuff = true;
      });
    }
  }

  Expanded _buildHitArea() {
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;
    return Expanded(
      child: GestureDetector(
        //垂直亮度和声音
        onVerticalDragDown: _onVerticalDragDown,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        onTap: _toggleAndRestartTimer,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              children: <Widget>[
                if (showBrightness)
                  LinearProgress(brighting, Icons.brightness_6),
                if (showVolTip) LinearProgress(volProgress, Icons.volume_up),
                if (showTimeLine)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    width: MediaQuery.of(context).size.width / 4,
                    height: barHeight,
                    child: Center(
                      child: Text(
                        '${formatDuration(initPos + Duration(seconds: _horizontalDragTime))} / ${formatDuration(duration)}',
                        style: TextStyle(color: chewieController.fontColor),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(VideoPlayerController controller) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Icon(
                (_latestValue != null && _latestValue.volume > 0)
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: chewieController.fontColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(horizontal: 2.0),
        padding: EdgeInsets.symmetric(horizontal: 2.0),
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: chewieController.fontColor,
        ),
      ),
    );
  }

  Widget _buildPosition() {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: Text(
        '${formatDuration(position)} / ${formatDuration(duration)}',
        style: TextStyle(
          fontSize: 13.0,
          color: chewieController.fontColor,
        ),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }

    // await _initDlna();

    // maxVol = await Volume.getMaxVol;
  }

//   Future<void> _initDlna() async {
//     if (!chewieController.enableDLNA) return;

// //    FlutterPlugin.search();
//     FlutterPlugin.init((List<dynamic> data) {
//       if (!mounted) return;

//       chewieController.devices = data;
//     });
//     await FlutterPlugin.devices;
//     print('dlna devices ${chewieController.devices}');
//   }

//   Widget _buildDlna() {
//     if (chewieController.devices.length == 0) {
//       return Container(
//         color: Colors.purple.withOpacity(0.4),
//         padding: EdgeInsets.all(20.0),
//         child: Center(
//           child: Text(
//             "暂无可用设备,请确保两者在同一wifi下.",
//             style: TextStyle(
//               color: Colors.white,
//             ),
//           ),
//         ),
//       );
//     }
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: <Widget>[
//         Expanded(
//             child: Container(
//           color: Colors.purple.withOpacity(0.4),
//           width: 300,
//           child: ListView(
//             padding: EdgeInsets.all(0),
//             children: chewieController.devices
//                 .map<Widget>((item) => ListTile(
//                       title: Text(
//                         item["name"],
//                         style: TextStyle(fontSize: 14.0),
//                       ),
//                       subtitle: Text(
//                         item["ip"],
//                         style: TextStyle(fontSize: 10.0),
//                       ),
//                       onTap: () async {
// //                        FlutterPlugin.playLocalSource(item["uuid"],
// //                            chewieController.videoPlayerController.dataSource);
//                       },
//                     ))
//                 .toList(),
//           ),
//         ))
//       ],
//     );
//   }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 2.0, left: 2.0),
        child: MaterialVideoProgressBar(
          controller,
          onDragStart: () {
            _hideTimer?.cancel();
          },
          onDragEnd: _startHideTimer,
          colors: chewieController.materialProgressColors ??
              ChewieProgressColors(
                playedColor: Theme.of(context).accentColor,
                handleColor: Theme.of(context).accentColor,
                bufferedColor: Theme.of(context).backgroundColor,
                backgroundColor: Theme.of(context).disabledColor,
              ),
        ),
      ),
    );
  }
}
