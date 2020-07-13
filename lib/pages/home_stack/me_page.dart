import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/utils/version_util.dart';
import 'package:clicli_dark/widgets/CustomSwitch.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MePage extends StatefulWidget {
  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<TriggerLogin>().listen((e) {
      getLocalProfile();
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
    final textStyle =
        TextStyle(color: Theme.of(context).accentColor, fontSize: 24);
    super.build(context);
    final ctx = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('个人中心', style: textStyle),
        ),
        body: ListView(
          children: <Widget>[
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
                    Navigator.pushNamed(context, 'CliCli://login');
                },
                leading: CachedNetworkImage(
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
                    trailing: CustomSwitch(
                      activeColor: ctx.accentColor,
                      value: isDarkTheme,
                      onChanged: (bool val) {
                        toggleDarkMode(val: val);
                      },
                    ),
                    onTap: toggleDarkMode,
                  ),
                  ListTile(
                    title: Text('更新表'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pushNamed(context, 'CliCli://timeline');
                    },
                  ),
                  ListTile(
                    title: Text('历史记录'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.pushNamed(context, 'CliCli://history');
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
                    title: Text('番剧报错'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      launch(
                          'https://github.com/cliclitv/clicli-dark/issues/new?assignees=&labels=%E7%95%AA%E5%89%A7%E6%8A%A5%E9%94%99&template=----.md&title=');
                    },
                  ),
                  ListTile(
                    title: Text('检查更新'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: checkAppUpdate,
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 20),
              child: Text(
                'APP VERSION ${Instances.appVersion}',
                style: Theme.of(context).textTheme.caption,
              ),
            )
          ],
        ));
  }
}
