import 'dart:async';
import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:clicli_dark/widgets/post_card.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  List data;
  String key;
  bool isLoading = false;

  Duration durationTime = Duration(milliseconds: 500);
  Timer timer;

  Future<void> _loadData({reset = false}) async {
    if (key.length < 1) {
      data = [];
      return;
    }

    setState(() {
      isLoading = true;
    });

    final res = (await getSearch(key)).data;
    if (reset) {
      data = jsonDecode(res)['posts'] ?? [];
    } else {
      data.addAll(jsonDecode(res)['posts']);
    }

    setState(() {
      isLoading = false;
    });
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
                    margin: EdgeInsets.fromLTRB(0, 5, 15, 5),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: TextField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      ),
                      onChanged: (v) {
                        key = v;
                        timer?.cancel();
                        timer = new Timer(durationTime, () {
                          _loadData(reset: true);
                        });
                      },
                    ),
                  ))
                ],
              ),
            ),
            if (data != null)
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : data.length > 0
                        ? Grid2RowView(List<PostCard>.generate(
                            data.length, (i) => PostCard(data[i])))
                        : Center(
                            child: Text(
                            '这里什么都没有 (⊙x⊙;)',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          )),
              )
          ],
        ),
      ),
    );
  }
}
