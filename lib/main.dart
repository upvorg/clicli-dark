import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/pages/home_stack/home_page.dart';
import 'package:clicli_dark/pages/home_stack/me_page.dart';
import 'package:clicli_dark/pages/home_stack/time_line_page.dart';
import 'package:clicli_dark/pages/home_stack/ugc_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize();
  await Instances.init();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkTheme = Instances.sp.getBool('isDarkTheme') ?? false;

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<ChangeTheme>().listen((e) {
      setState(() {
        isDarkTheme = e.val;
      });
      ThemeManager.toggleAppbarTheme(e.val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Instances.navigatorKey,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.system,
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      home: MyHomePage(),
      title: 'CliCli',
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<IconData> pagesIcon = [
    Icons.home,
    Icons.timeline,
    Icons.explore,
    Icons.supervised_user_circle
  ];

  int _currentPageIndex = 0;
  final _pageController = PageController();

  void _onPageChange(int index) {
    if (index == _currentPageIndex) return;
    setState(() {
      _currentPageIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 1), curve: Curves.ease);
    });
  }

  int lastBack = 0;

  Future<bool> _doubleBackExit() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastBack > 1000) {
      Instances.scaffoldState.showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Text('再按一次退出应用'),
        ),
      );
      lastBack = DateTime.now().millisecondsSinceEpoch;
      return Future.value(false);
    } else {
      //  SystemNavigator.pop();
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: _doubleBackExit,
      child: Scaffold(
          key: Instances.homeStackscaffoldKey,
          body: PageView(
            controller: _pageController,
            children: [HomePage(), TimeLinePage(), UGCPage(), MePage()],
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: BottomAppBar(
            color: theme.cardColor,
            elevation: 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                pagesIcon.length,
                (i) => Expanded(
                  child: IconButton(
                    icon: Icon(
                      pagesIcon[i],
                      color: _currentPageIndex == i
                          ? theme.primaryColor
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
