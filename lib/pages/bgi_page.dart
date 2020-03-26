import 'dart:convert';

import 'package:clicli_dark/instance.dart';
import 'package:clicli_dark/pages/player_page.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:clicli_dark/widgets/common_widget.dart';
import 'package:flutter/material.dart';

class BgiPage extends StatefulWidget {
  @override
  _BgiPageState createState() => _BgiPageState();
}

class _BgiPageState extends State<BgiPage> {
  List bgiList;
  List hisList;

  @override
  void initState() {
    super.initState();
    getBgi();
  }

  Future<void> getBgi() async {
    setState(() {
      bgiList = jsonDecode(Instances.sp.getString('followBgi') ?? '[]');
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
        child: FixedAppBar(title: Text('我的追番')),
      ),
      body: RefreshIndicator(
        child: ListView.builder(
          itemBuilder: (_, i) {
            return GestureDetector(
              onTap: () {
                final int index =
                    hisList.indexWhere((f) => f['id'] == bgiList[i]['id']);
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return PlayerPage(
                    data: bgiList[i]['data'],
                    pos: hisList[index]['curr'],
                  );
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
                          bgiList[i]['thumb'],
                          fit: BoxFit.cover,
                          width: w,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[ellipsisText(bgiList[i]['name'])],
                        ),
                      )
                    ],
                  )),
            );
          },
          itemCount: bgiList.length,
        ),
        onRefresh: getBgi,
      ),
    );
  }
}
