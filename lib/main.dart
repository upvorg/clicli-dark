import 'dart:io';

import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/pages/home_stack/home_page.dart';
import 'package:clicli_dark/pages/home_stack/time_line_page.dart';
import 'package:clicli_dark/pages/home_stack/ugc_page.dart';
import 'package:clicli_dark/utils/dio_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
    ));
  }
  await NetUtils.initConfig();
  await FlutterDownloader.initialize();
  await Future.delayed(Duration(milliseconds: 1000));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Instances.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        highlightColor: Colors.transparent,
        splashFactory: const NoSplashFactory(),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final List<IconData> pagesIcon = [
    Icons.home,
    Icons.timeline,
    Icons.explore
  ];

  int _currentPageIndex = 0;
  final _pageController = PageController();

  void _onPageChange(int index) {
    setState(() {
      _currentPageIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 1), curve: Curves.ease);
    });
  }

  int lastBack = 0;

  Future<bool> doubleBackExit() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastBack > 1000) {
      Instances.scaffoldState.showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Text('再按一次退出应用'),
        ),
      );
      lastBack = DateTime.now().millisecondsSinceEpoch;
    } else {
      //  SystemNavigator.pop();
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: doubleBackExit,
      child: Scaffold(
          key: Instances.homeStackscaffoldKey,
          body: PageView(
            controller: _pageController,
            children: [HomePage(), TimeLinePage(), UGCPage()],
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 2.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                pagesIcon.length,
                (i) => Expanded(
                  child: IconButton(
                    icon: Icon(
                      pagesIcon[i],
                      color: _currentPageIndex == i
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () {
                      _onPageChange(i);
                    },
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
/*

static const MethodChannel _methodChannel =
  const MethodChannel('flutter_volume');
  static Future<double> get volume async => (await _methodChannel.invokeMethod('volume')) as double;
  static Future setVolume(double volume) => _methodChannel.invokeMethod('setVolume', {"volume" : volume});


  */

/*

import 'package:flutter/cupertino.dart';

class RankPage extends StatefulWidget {
  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

*/

class NoSplashFactory extends InteractiveInkFeatureFactory {
  const NoSplashFactory();

  InteractiveInkFeature create({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required Offset position,
    @required Color color,
    TextDirection textDirection,
    bool containedInkWell: false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    VoidCallback onRemoved,
  }) {
    return new NoSplash(
      controller: controller,
      referenceBox: referenceBox,
      color: color,
      onRemoved: onRemoved,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    Color color,
    VoidCallback onRemoved,
  })  : assert(controller != null),
        assert(referenceBox != null),
        super(
            controller: controller,
            referenceBox: referenceBox,
            onRemoved: onRemoved) {
    controller.addInkFeature(this);
  }
  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}
