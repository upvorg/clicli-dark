import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/widgets//post_card.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:clicli_dark/widgets/refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UGCPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UGCPageState();
  }
}

class _UGCPageState extends State<UGCPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ScrollController _scrollController = new ScrollController();
  List data = [];
  int page = 1;

  Future<void> getUGC() async {
    final res = (await getPost('原创', '', page, 10)).data;
    data.addAll(jsonDecode(res)['posts']);
    page += 1;
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Column(
      children: <Widget>[
        HomeStackTitleAppbar('UGC'),
        Expanded(
          child: RefreshWrapper(
            onLoadMore: getUGC,
            onRefresh: getUGC,
            scrollController: _scrollController,
            child: Grid2RowView(
              controller: _scrollController,
              itemBuilder: (_, i) => PostCard(data[i]),
              len: data.length,
            ),
          ),
        )
      ],
    ));
  }
}
