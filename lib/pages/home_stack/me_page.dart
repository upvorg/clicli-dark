import 'dart:convert';

import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/pages/bgi_page.dart';
import 'package:clicli_dark/pages/faq_page.dart';
import 'package:clicli_dark/pages/history_page.dart';
import 'package:clicli_dark/pages/login_page.dart';
import 'package:clicli_dark/utils/toast_utils.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:clicli_dark/utils/version_util.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class MePage extends StatefulWidget {
  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  String version = '';

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<TriggerLogin>().listen((e) {
      getLocalProfile();
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      final String v = packageInfo.version;
      final String buildNumber = packageInfo.buildNumber;
      version = '$v.$buildNumber';
      setState(() {});
    });
    getLocalProfile();
  }

  Map userInfo;
  getLocalProfile() {
    final u = Instances.sp.getString('userinfo');
    userInfo = u != null
        ? jsonDecode(u)
        : {'name': '点击登录', 'desc': '这个人很酷，没有签名', 'qq': '1'};
    setState(() {});
  }

  Future<void> checkAppUpdate(BuildContext ctx) async {
    int status;

    try {
      status = await VersionManager.checkUpdate();
      if (status > 0) {
        showDialog(
            barrierDismissible: false,
            context: Instances.currentContext,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('提示'),
                content: Text('有新版本可更新！'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('算了'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('更新'),
                    onPressed: () async {
                      if (await canLaunch('https://app.clicli.me/')) {
                        await launch('https://app.clicli.me/');
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      } else {
        showSnackBar('已是最新版本');
      }
    } catch (e) {
      showErrorSnackBar('检测更新失败');
    }
  }

  bool isDarkTheme = Instances.sp.getBool('isDarkTheme') ?? false;

  toggleDarkMode({bool val}) {
    if (val == null) {
      isDarkTheme = !isDarkTheme;
      Instances.eventBus.fire(ChangeTheme(isDarkTheme));
      Instances.sp.setBool('isDarkTheme', isDarkTheme);
    } else {
      setState(() {
        isDarkTheme = val;
        Instances.eventBus.fire(ChangeTheme(val));
        Instances.sp.setBool('isDarkTheme', val);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctx = Theme.of(context);
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            HomeStackTitleAppbar('个人中心'),
            Container(
              color: ctx.cardColor,
              child: ListTile(
                onLongPress: () {
                  Instances.sp.remove('usertoken');
                  Instances.sp.remove('userinfo');
                  getLocalProfile();
                },
                onTap: () {
                  if (userInfo['qq'] == '1' || userInfo['qq'] == null)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage(),
                      ),
                    );
                },
                leading: OptimizedCacheImage(
                  imageUrl:
                      'http://q1.qlogo.cn/g?b=qq&nk=${userInfo['qq']}&s=5',
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
                title: Text(userInfo['name']),
                subtitle: Text(userInfo['desc']),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              color: ctx.cardColor,
              child: ListBody(
                children: <Widget>[
                  ListTile(
                    title: const Text('暗黑模式'),
                    trailing: Switch(
                      value: isDarkTheme,
                      onChanged: (bool val) {
                        toggleDarkMode(val: val);
                      },
                    ),
                    onTap: toggleDarkMode,
                  ),
                  ListTile(
                    title: Text('我的追番'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return BgiPage();
                      }), (Route<dynamic> route) => true);
                    },
                  ),
                  ListTile(
                    title: Text('历史记录'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return HistoryPage();
                      }), (Route<dynamic> route) => true);
                    },
                  ),
                  ListTile(
                    title: Text('企鹅 Q 群'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      const QQGroupLink =
                          'https://jq.qq.com/?_wv=1027&k=5lfSD1B';
                      if (await canLaunch(QQGroupLink)) {
                        await launch(QQGroupLink);
                      }
                    },
                  ),
                  ListTile(
                    title: Text('常见问题'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return FAQPage();
                      }), (Route<dynamic> route) => true);
                    },
                  ),
                  ListTile(
                    title: Text('检查更新'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      checkAppUpdate(context);
                    },
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 20),
              child: Text(
                'APP VERSION $version',
                style: Theme.of(context).textTheme.caption,
              ),
            )
          ],
        ),
      ),
    ));
  }
}
