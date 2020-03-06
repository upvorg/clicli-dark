import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/utils/toast_utils.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  String name = '';
  String pwd = '';
  bool isDo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FixedAppBar(
            centerTitle: true,
            title: Text('登录'),
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  maxLines: 1,
                  maxLengthEnforced: true,
                  decoration: InputDecoration(labelText: '用户名'),
                  onChanged: (v) {
                    name = v;
                  },
                ),
                TextField(
                  maxLines: 1,
                  maxLengthEnforced: true,
                  decoration: InputDecoration(labelText: '密码'),
                  obscureText: true,
                  onChanged: (v) {
                    pwd = v;
                  },
                ),
                SizedBox(height: 20),
                MaterialButton(
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    '登录',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: isDo
                      ? null
                      : () async {
                          showSnackBar('登录中···');
                          setState(() {
                            isDo = true;
                          });
                          final res = jsonDecode(
                              (await login({'name': name, 'pwd': pwd})).data);

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
                            Instances.sp
                                .setString('userinfo', jsonEncode(res['user']));
                            Instances.eventBus.fire(TriggerLogin());
                            Navigator.pop(context);
                          }
                        },
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
