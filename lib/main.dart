import 'dart:io';

import 'package:clicili_dark/pages/home_stack/home_page.dart';
import 'package:clicili_dark/pages/home_stack/time_line_page.dart';
import 'package:clicili_dark/pages/home_stack/ugc_page.dart';
import 'package:clicili_dark/utils/dio_utils.dart';
import 'package:clicili_dark/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CLICLI Dark',
      theme: ThemeData(
        primarySwatch: Colors.purple,
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
  static final List<String> pagesTitle = ['首页', '应用', '消息', '我的'];
  static final List<String> pagesIcon = [
    'assets/home.svg',
    'assets/time.svg',
    'assets/other.svg',
    'assets/user.svg'
  ];
  int _tabIndex = 0;

  void _selectedTab(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  int lastBack = 0;

  Future<bool> doubleBackExit() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastBack > 1000) {
      showShortToast("再按一次退出应用");
      lastBack = DateTime.now().millisecondsSinceEpoch;
    } else {
      cancelToast();
      SystemNavigator.pop();
    }
    return Future.value(false);
  }

  Widget get comingSoon => Center(child: Text('敬 请 期 待'));

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
        body: IndexedStack(
          // TODO 懒加载
          children: <Widget>[HomePage(), TimeLinePage(), UGCPage(), comingSoon],
          index: _tabIndex,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: _selectedTab,
          type: BottomNavigationBarType.fixed,
          items: [
            for (int i = 0; i < pagesTitle.length; i++)
              BottomNavigationBarItem(
                title: SizedBox.shrink(),
                icon: SvgPicture.asset(
                  pagesIcon[i],
                  color: _tabIndex == i
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  height: 28,
                ),
              )
          ],
        ),
      ),
    );
  }
}

/*

import 'package:flutter/material.dart';

class Page extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<age>{
  @override
  Widget build(BuildContext context) {

    return null;
  }
}
*/
