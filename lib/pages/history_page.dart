import 'dart:convert';

import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/pages/player_page.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:clicli_dark/widgets/common_widget.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List hisList;

  @override
  void initState() {
    super.initState();
    getHis();
  }

  Future<void> getHis() async {
    setState(() {
      hisList = jsonDecode(Instances.sp.getString('history') ?? '[]');
    });
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height / 8;
    final w = MediaQuery.of(context).size.width / 3;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: FixedAppBar(title: Text('历史记录')),
      ),
      body: RefreshIndicator(
        child: ListView.builder(
          itemBuilder: (_, i) {
            return GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return PlayerPage(
                      data: hisList[i]['data'], pos: hisList[i]['curr']);
                }), (Route<dynamic> route) => true);
              },
              child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 2),
                  padding: EdgeInsets.all(5),
                  height: size,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Image.network(
                          hisList[i]['thumb'],
                          fit: BoxFit.cover,
                          width: w,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ellipsisText(hisList[i]['name']),
                            SizedBox(height: 5),
                            Text('第 ${hisList[i]['curr'] + 1} 集'),
                            if (hisList[i]['time'] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                    '${DateTime.fromMillisecondsSinceEpoch(hisList[i]['time']).toLocal()}'),
                              )
                          ],
                        ),
                      )
                    ],
                  )),
            );
          },
          itemCount: hisList.length,
        ),
        onRefresh: getHis,
      ),
    );
  }
}
