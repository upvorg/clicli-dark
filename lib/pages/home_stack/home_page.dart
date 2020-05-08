import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/pages/rank_page.dart';
import 'package:clicli_dark/pages/search_page.dart';
import 'package:clicli_dark/widgets//post_card.dart';
import 'package:clicli_dark/widgets/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const List<String> tabs = ["推荐", "最新"];

  TabController _tabController;
  final ScrollController _scrollController =
      new ScrollController(keepScrollOffset: true);
  final ScrollController _scrollController1 =
      new ScrollController(keepScrollOffset: true);

  List<int> page = [1, 1];
  List _reList = [];
  List _newList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: tabs.length,
      vsync: this,
    );
  }

  Future<void> initLoad() async {
    final res = (await getPost('', tabs[0], 1, 20)).data;
    _reList = jsonDecode(res)['posts'];
    setState(() {});
  }

  Future<void> initNewList() async {
    final res1 = (await getPost('bgm', '', 1, 20)).data;
    _newList = jsonDecode(res1)['posts'];
    setState(() {});
  }

  Future<void> _loadData({reset = false}) async {
    var res;
    final index = _tabController.index;
    final _page = reset ? 1 : page[index] + 1;

    if (index == 0) {
      res = (await getPost('', tabs[0], _page, 15)).data;
    } else {
      res = (await getPost('bgm', '', _page, 15)).data;
    }

    final List posts = jsonDecode(res)['posts'] ?? [];
    if (reset) {
      if (index == 0) {
        _reList = posts;
      } else {
        _newList = posts;
      }
      page[index] = 1;
    } else {
      if (index == 0) {
        _reList.addAll(posts);
      } else {
        _newList.addAll(posts);
      }
      page[index] = _page;
    }
    setState(() {});
  }

  void _to(BuildContext _, Widget w) {
    Navigator.push(_, MaterialPageRoute(builder: (__) => w));
  }

  void _toScrollTop(int index) {
    [_scrollController, _scrollController1][index]?.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  get appbar => AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: const BoxDecoration(),
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
              labelColor: Theme.of(context).accentColor,
              tabs: List<GestureDetector>.generate(
                tabs.length,
                (index) => GestureDetector(
                  child: Tab(text: tabs[index]),
                  onDoubleTap: () => _toScrollTop(index),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.whatshot,
                    color: Theme.of(context).accentColor,
                  ),
                  onPressed: () {
                    _to(context, RankPage());
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).accentColor,
                  ),
                  onPressed: () {
                    _to(context, SearchPage());
                  },
                ),
              ],
            )
          ],
        ),
      );

  @override
  void dispose() {
    _scrollController?.dispose();
    _scrollController1?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          RefreshWrapper(
            onLoadMore: _loadData,
            onRefresh: initLoad,
            scrollController: _scrollController,
            child: Grid2RowView(
              itemBuilder: (_, i) => PostCard(_reList[i]),
              controller: _scrollController,
              len: _reList.length,
            ),
          ),
          RefreshWrapper(
            onLoadMore: _loadData,
            onRefresh: initNewList,
            scrollController: _scrollController1,
            child: Grid2RowView(
              itemBuilder: (_, i) => PostCard(_newList[i]),
              controller: _scrollController1,
              len: _newList.length,
            ),
          ),
        ],
      ),
    );
  }
}
