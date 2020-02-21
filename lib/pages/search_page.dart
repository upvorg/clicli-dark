import 'dart:async';
import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:clicli_dark/widgets/post_card.dart';
import 'package:clicli_dark/widgets/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final Duration durationTime = Duration(milliseconds: 500);
  Timer timer;

  Future<void> _loadData({reset = false}) async {
    if (key.length < 1) {
      data = [];
      return;
    }

    setState(() {
      isLoading = true;
    });

    var res;
    if (int.tryParse(key) != null) {
      res = jsonDecode((await getPostDetail(int.parse(key))).data)['result'];
      data = [res];
    } else {
      res = (await getSearch(key)).data;
      if (reset) {
        data = jsonDecode(res)['posts'] ?? [];
      } else {
        data.addAll(jsonDecode(res)['posts']);
      }
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
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(5),
              child: Container(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.all(2),
                height: 35,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.6),
                        ),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: TextField(
                        maxLines: 1,
                        maxLengthEnforced: true,
                        autofocus: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                        ),
                        onChanged: (v) {
                          key = v;
                          timer?.cancel();
                          timer = Timer(durationTime, () {
                            _loadData(reset: true);
                          });
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(15)],
                      ),
                    ),
                  ],
                ),
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

class TagPage extends StatefulWidget {
  final String tag;

  TagPage(this.tag);

  @override
  State<StatefulWidget> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  final ScrollController _scrollController = ScrollController();

  List data = [];
  int page = 1;

  Future<void> getTagList() async {
    data.addAll(jsonDecode(
        (await getPost('', widget.tag, page, 10, status: 'nowait'))
            .data)['posts']);
    setState(() {});
  }

  Future<void> getNextList() async {
    page = page + 1;
    await getTagList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        HomeStackTitleAppbar(widget.tag),
        Expanded(
          child: RefreshWrapper(
            scrollController: _scrollController,
            onRefresh: getTagList,
            onLoadMore: getNextList,
            child: Grid2RowView(
              List.generate(data.length, (i) => PostCard(data[i])),
              controller: _scrollController,
            ),
          ),
        ),
      ],
    ));
  }
}
