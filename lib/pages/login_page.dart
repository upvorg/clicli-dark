import 'dart:convert';
import 'dart:ui';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/utils/toast_utils.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = '';
  String pwd = '';
  bool isDo = false;

  _login() async {
    if (name.length < 1 || pwd.length < 1) {
      showSnackBar('什么都没有输入');
      return;
    }
    showSnackBar('登录中···');
    setState(() {
      isDo = true;
    });
    final res = jsonDecode((await login({'name': name, 'pwd': pwd})).data);

    if (res['code'] != 200) {
      showErrorSnackBar(res['msg']);
      setState(() {
        isDo = false;
      });
    } else {
      setState(() {
        isDo = false;
      });
      Instances.sp.setString('usertoken', res['token']);
      Instances.sp.setString('userinfo', jsonEncode(res['user']));
      Instances.eventBus.fire(TriggerLogin());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/login_bg.webp'),
          ),
        ),
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                FlatButton(
                  child: Text('注册'),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      'CliCli://webView',
                      arguments: {'url': 'https://admin.clicli.me/register'},
                    );
                  },
                )
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 6),
            Center(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          maxLines: 1,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            labelText: '用户名',
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                          onChanged: (v) {
                            name = v;
                          },
                        ),
                        TextField(
                          maxLines: 1,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            labelText: '密码',
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                          obscureText: true,
                          onChanged: (v) {
                            pwd = v;
                          },
                        ),
                        SizedBox(height: 20),
                        FlatButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            '登录',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: isDo ? null : _login,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
