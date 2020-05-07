import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/widgets//post_card.dart';
import 'package:clicli_dark/widgets/loading2load.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeLinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TimeLineState();
  }
}

class _TimeLineState extends State<TimeLinePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const List week = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  List<List> data = [[], [], [], [], [], [], []];

  Future<void> getUGC() async {
    data = [[], [], [], [], [], [], []];
    final res = (await getPost('新番', '', 1, 100, status: 'nowait')).data;
    final List _res = jsonDecode(res)['posts'];

    _res.forEach((f) {
      final t = f['time'] + ''.replaceAll('-', '/');
      final day = DateTime.parse(t).weekday - 1;

      if (data[day] == null) data[day] = [];
      data[day].add(f);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: KLoading2Load(
        load: getUGC,
        child: RefreshIndicator(
          onRefresh: getUGC,
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(0),
            children: [
              for (int i = 0; i < data.length; i++)
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        week[i],
                        style: theme.textTheme.headline6
                            .copyWith(color: theme.accentColor),
                      ),
                    ),
                    for (int j = 0;
                        j <
                            ((data[i].length % 2 > 0)
                                ? data[i].length ~/ 2 + 1
                                : data[i].length ~/ 2);
                        j++)
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 5, 5, 5),
                              child: PostCard(data[i][j * 2]),
                            ),
                          ),
                          data[i].length > j * 2 + 1
                              ? Expanded(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 5, 10, 5),
                                    child: PostCard(data[i][j * 2 + 1]),
                                  ),
                                )
                              : Expanded(child: Container())
                        ],
                      )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
