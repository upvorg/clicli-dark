import 'dart:convert';

import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/pages/login_page.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MePage extends StatefulWidget {
  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            HomeStackTitleAppbar('个人中心'),
            GestureDetector(
              onTap: () {
                if (userInfo['qq'] == '1' || userInfo['qq'] == null)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage(),
                    ),
                  );
              },
              onDoubleTap: () {
                Instances.sp.remove('usertoken');
                Instances.sp.remove('userinfo');
                getLocalProfile();
              },
              child: Container(
                color: Colors.white,
                child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl:
                        'http://q1.qlogo.cn/g?b=qq&nk=${userInfo['qq']}&s=5',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  title: Text(userInfo['name']),
                  subtitle: Text(userInfo['desc']),
                  trailing: Icon(Icons.settings),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              color: Colors.white,
              child: ListBody(
                children: <Widget>[
                  ListTile(
                    title: Text('我的追番'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                  ListTile(
                    title: Text('历史记录'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                  ListTile(
                    title: Text('稿件管理'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                  ListTile(
                    title: Text(' QQ 群'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      const QQGroupLink =
                          'https://jq.qq.com/?_wv=1027&k=5iTBWlY';
                      if (await canLaunch(QQGroupLink)) {
                        await launch(QQGroupLink);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
