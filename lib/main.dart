import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/pages/bgi_page.dart';
import 'package:clicli_dark/pages/home_stack/home_page.dart';
import 'package:clicli_dark/pages/home_stack/me_page.dart';
import 'package:clicli_dark/pages/home_stack/time_line_page.dart';
import 'package:clicli_dark/pages/home_stack/ugc_page.dart';
import 'package:clicli_dark/pages/login_page.dart';
import 'package:clicli_dark/pages/player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await Instances.init();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(CliCliApp());
}

class CliCliApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CliCliAppState();
}

class _CliCliAppState extends State<CliCliApp> {
  bool isDarkTheme = Instances.sp.getBool('isDarkTheme') ?? false;

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<ChangeTheme>().listen((e) {
      setState(() {
        isDarkTheme = e.val;
      });
    });
  }

  @override
  dispose() {
    Instances.eventBus.destroy();
    super.dispose();
  }

  Route _onGenerateRoute(RouteSettings settings) {
    final Map<String, WidgetBuilder> routes = {
      'CliCli://': (_) => HomePage(),
      'CliCli://home': (_) => HomePage(),
      'CliCli://player': (_) => PlayerPage(),
      'CliCli://login': (_) => LoginPage(),
      'CliCli://fav': (_) => BgiPage(),
      // '/webView': (_) {
      //   Map arg = settings.arguments;
      //   return WebviewScaffold(
      //     url: arg['url'],
      //     appBar: AppBar(
      //       textTheme: TextTheme(
      //         title: TextStyle(
      //           color: Colors.white,
      //           fontSize: 18,
      //         ),
      //       ),
      //       title: Text(arg['title']),
      //     ),
      //   );
      // },
    };

    final WidgetBuilder widget = routes[settings.name];

    if (widget != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: routes[settings.name],
      );
    }

    return null;
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
      onGenerateRoute: _onGenerateRoute,
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
  final _pages = [HomePage(), TimeLinePage(), UGCPage(), MePage()];

  int _currentPageIndex = 0;
  final _pageController = PageController();

  void _onPageChange(int index) {
    if (index == _currentPageIndex) return;
    setState(() {
      _currentPageIndex = index;
      _pageController.jumpToPage(index);
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
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: _doubleBackExit,
      child: Scaffold(
        key: Instances.homeStackscaffoldKey,
        body: PageView.builder(
          itemCount: pagesIcon.length,
          controller: _pageController,
          itemBuilder: (context, index) => _pages[index],
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              pagesIcon.length,
              (i) => Expanded(
                child: IconButton(
                  icon: Icon(
                    pagesIcon[i],
                    color: _currentPageIndex == i
                        ? theme.accentColor
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
        ),
        floatingActionButton: _currentPageIndex != 0
            ? null
            : FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, 'CliCli://fav'),
                tooltip: 'FAV',
                child: Icon(Icons.live_tv),
              ),
      ),
    );
  }
}
