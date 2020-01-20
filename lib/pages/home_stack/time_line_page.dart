import 'dart:convert';

import 'package:clicili_dark/api/post.dart';
import 'package:clicili_dark/widgets//post_card.dart';
import 'package:clicili_dark/widgets/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_list/extended_list.dart';

class TimeLinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TimeLineState();
  }
}

class _TimeLineState extends State<TimeLinePage> {
  final List week = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  bool hasLoad = false;
  List<List> data = [[], [], [], [], [], [], []];

  @override
  void initState() {
    getUGC();
    super.initState();
  }

  Future<void> getUGC() async {
    final res = (await getPost('新番', '', 1, 100)).data;
    final List _res = jsonDecode(res)['posts'];

    _res.forEach((f) {
      final t = f['time'] + ''.replaceAll('-', '/');
      final day = DateTime.parse(t).weekday - 1;

      if (data[day] == null) data[day] = [];
      data[day].add(f);
    });
    hasLoad = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      HomeStackTitleAppbar('时间表'),
      Expanded(
          child: hasLoad
              ? RefreshIndicator(
                  onRefresh: getUGC,
                  child: ExtendedListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    children: [
                      for (int i = 0; i < data.length; i++)
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text(week[i]),
                            ),
                            for (int j = 0; j < data[i].length / 2; j++)
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: PostCard(data[i][(j + 1) * 2 - 2]),
                                    ),
                                  ),
                                  data[i].length > (j + 1) * 2 - 1
                                      ? Expanded(
                                          child: Container(
                                            margin: EdgeInsets.all(10),
                                            child: PostCard(
                                                data[i][(j + 1) * 2 - 1]),
                                          ),
                                        )
                                      : Expanded(child: Container())
                                ],
                              )
                          ],
                        )
                    ],
                  ),
                )
              : Center(child: CircularProgressIndicator()))
    ]));
  }
}
