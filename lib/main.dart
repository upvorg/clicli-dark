import 'dart:io';

import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/pages/home_stack/home_page.dart';
import 'package:clicli_dark/pages/home_stack/time_line_page.dart';
import 'package:clicli_dark/pages/home_stack/ugc_page.dart';
import 'package:clicli_dark/utils/dio_utils.dart';
import 'package:clicli_dark/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          key: Instances.scaffoldKey,
          body: MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: Instances.navigatorKey,
            theme: ThemeData(primarySwatch: Colors.purple),
            home: MyHomePage(),
          )),
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
      showSnackBar("再按一次退出应用");
      lastBack = DateTime.now().millisecondsSinceEpoch;
    } else {
      cancelSnackBar();
      //  SystemNavigator.pop();
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  void initState() {
    super.initState();
    NetUtils.initConfig();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: doubleBackExit,
      child: Scaffold(
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
