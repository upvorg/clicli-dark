import 'dart:async';
import 'dart:convert';

import 'package:clicili_dark/api/post.dart';
import 'package:clicili_dark/widgets/appbar.dart';
import 'package:clicili_dark/widgets/post_card.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  ScrollController _scrollController = ScrollController();

  int page = 1;
  List data;
  String key;

  Duration durationTime = Duration(milliseconds: 500);
  Timer timer;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadData();
      }
    });

    super.initState();
  }

  Future<void> _loadData({reset = false}) async {
    print('load');
    if (key.length < 1) {
      data = [];
      return;
    }

    final _page = reset ? 1 : page + 1;
    final res = (await getSearch(key)).data;

    if (reset) {
      data = jsonDecode(res)['posts'] ?? [];
      page = 1;
    } else {
      data.addAll(jsonDecode(res)['posts']);
      page = _page;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            FixedAppBar(
              automaticallyImplyLeading: false,
              title: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10)),
                      onChanged: (v) {
                        key = v;
                        timer?.cancel();
                        timer = new Timer(durationTime, () {
                          _loadData(reset: true);
                        });
                        setState(() {});
                      },
                    ),
                  ))
                ],
              ),
            ),
            Expanded(
              child: data == null
                  ? Container()
                  : data.length > 1
                      ? GridView.count(
                          controller: _scrollController,
                          crossAxisSpacing: 15.0,
                          mainAxisSpacing: 20.0,
                          padding: EdgeInsets.all(10.0),
                          crossAxisCount: 2,
                          children: data.map((f) => PostCard(f)).toList(),
                        )
                      : Center(child: Text('这里什么都没有')),
            )
          ],
        ),
      ),
    );
  }
}
