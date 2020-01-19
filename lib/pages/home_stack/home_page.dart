import 'dart:convert';

import 'package:clicili_dark/api/post.dart';
import 'package:clicili_dark/pages/search_page.dart';
import 'package:clicili_dark/utils/toast_utils.dart';
import 'package:clicili_dark/widgets//post_card.dart';
import 'package:clicili_dark/widgets/appbar.dart';
import 'package:clicili_dark/widgets/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<String> tabs = ["推荐", "最新"];

  TabController _tabController;
  ScrollController _scrollController =
      new ScrollController(keepScrollOffset: true);
  ScrollController _scrollController1 =
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
    initLoad();
  }

  Future<void> initLoad() async {
    final res = (await getPost('', tabs[0], 1, 10)).data;
    final res1 = (await getPost('bgm', '', 1, 10)).data;

    _reList = jsonDecode(res)['posts'];
    _newList = jsonDecode(res1)['posts'];
    setState(() {});
  }

  Future<void> _loadData({reset = false}) async {
    var res;
    final index = _tabController.index;
    final _page = reset ? 1 : page[index] + 1;

    if (index == 0) {
      res = (await getPost('', tabs[0], _page, 10)).data;
    } else {
      res = (await getPost('bgm', '', _page, 10)).data;
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

  Widget getTabPage(List data, ScrollController c) {
    if (data.length < 1) Center(child: CircularProgressIndicator());

    return RefreshWrapper(
      onLoadMore: _loadData,
      onRefresh: () async {
        await _loadData(reset: true);
      },
      scrollController: c,
      child: GridView.builder(
        itemBuilder: (BuildContext ctx, int i) {
          return PostCard(data[i]);
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 20.0,
          crossAxisCount: 2,
          childAspectRatio: 2 / 2,
        ),
        itemCount: data.length,
        controller: c,
        padding: EdgeInsets.all(10.0),
      ),
    );
  }

  get appbar => FixedAppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorPadding:
                    EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                labelColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                tabs: List<Tab>.generate(
                  tabs.length,
                  (index) => Tab(text: tabs[index]),
                ),
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.show_chart,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      showCenterErrorShortToast('这里不可以哦 ~');
                      //  Navigator.push(
                      //      context,
                      //      MaterialPageRoute(
                      //          builder: (BuildContext context) => SearchPage()));
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => SearchPage(),
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          appbar,
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                getTabPage(_reList, _scrollController),
                getTabPage(_newList, _scrollController1),
              ],
            ),
          )
        ],
      ),
    );
  }
}
