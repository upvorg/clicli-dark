import 'dart:convert';

import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/pages/player_page.dart';
import 'package:clicli_dark/widgets/common_widget.dart';
import 'package:flutter/material.dart';

class BgiPage extends StatefulWidget {
  @override
  _BgiPageState createState() => _BgiPageState();
}

class _BgiPageState extends State<BgiPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List bgiList = [];
  List hisList = [];

  @override
  void initState() {
    super.initState();
    getBgi();
  }

  Future<void> getBgi() async {
    setState(() {
      final List _bgiList =
          jsonDecode(Instances.sp.getString('followBgi') ?? '[]');
      _bgiList.sort((p, n) => n['time'].compareTo(p['time']));
      bgiList = _bgiList;
      hisList = jsonDecode(Instances.sp.getString('history') ?? '[]');
    });
    await Future.delayed(Duration(seconds: 1));
  }

  clearAll() {
    Instances.sp.remove('followBgi');
    bgiList = [];
    Instances.scaffoldState.showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 1000),
        content: Text('（￣︶￣）↗　'),
      ),
    );
    setState(() {});
  }

  removeItem(DismissDirection _, int i) {
    if (_ == DismissDirection.endToStart) {
      bgiList.removeAt(i);
      Instances.scaffoldState.showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Text('（￣︶￣）↗　'),
        ),
      );
      Instances.sp.setString('followBgi', jsonEncode(bgiList));
    }
  }

  _toPlay(int i, int curr) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerPage(
          data: bgiList[i]['data'],
          pos: curr,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final h = MediaQuery.of(context).size.height;
    final size = h / 6;
    final w = MediaQuery.of(context).size.width / 3;
    final color = Theme.of(context).cardColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '我的追番',
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text('清空', style: Theme.of(context).textTheme.caption),
            onPressed: clearAll,
          )
        ],
      ),
      body: RefreshIndicator(
        child: bgiList.length > 0
            ? ListView.builder(
                itemBuilder: (_, i) {
                  final jj = hisList.firstWhere(
                      (element) => element['id'] == bgiList[i]['id'],
                      orElse: () => {'curr': 0});
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key('key_$i'),
                    onDismissed: (DismissDirection _) => removeItem(_, i),
                    child: GestureDetector(
                      onTap: () {
                        _toPlay(i, jj['curr']);
                      },
                      child: Container(
                          color: color,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          height: size,
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: Image.network(
                                  bgiList[i]['thumb'],
                                  fit: BoxFit.cover,
                                  width: w,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ellipsisText(bgiList[i]['name']),
                                    SizedBox(height: 10),
                                    Text("已观看到第 ${jj['curr'] + 1} 集"),
                                  ],
                                ),
                              )
                            ],
                          )),
                    ),
                  );
                },
                itemCount: bgiList.length,
              )
            : Container(
                alignment: Alignment.center,
                height: double.infinity,
                child: Text(
                  '空空如也 (＃°Д°)',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        onRefresh: getBgi,
      ),
    );
  }
}
