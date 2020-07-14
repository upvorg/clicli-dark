import 'dart:convert';

import 'package:clicli_dark/api/post.dart';
import 'package:clicli_dark/pages/player_page.dart';
import 'package:clicli_dark/utils/reg_utils.dart';
import 'package:clicli_dark/widgets/loading2load.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RankPage extends StatefulWidget {
  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  List rankList = [];

  getRankInfo() async {
    rankList = jsonDecode((await getRank()).data)['posts'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        TextStyle(color: Theme.of(context).accentColor, fontSize: 24);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('排行榜', style: textStyle),
      ),
      body: KLoading2Load(
        load: getRankInfo,
        child: ListView.builder(
          padding: EdgeInsets.all(0),
          physics: BouncingScrollPhysics(),
          itemCount: rankList.length,
          itemBuilder: (ctx, i) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            PlayerPage(data: rankList[i])));
              },
              child: Container(
                color: Theme.of(context).cardColor,
                margin: EdgeInsets.symmetric(vertical: 2),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Image(
                        image: NetworkImage(getSuo(rankList[i]['content'])),
                        height: MediaQuery.of(context).size.height / 6,
                        width: MediaQuery.of(context).size.width / 5,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.width / 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              rankList[i]['title'].trimLeft(),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: Colors.purple),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: rankList[i]['tag']
                                  .split(' ')
                                  .map<Widget>((tag) => Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Text(
                                          tag.replaceAll(' ', ''),
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ))
                                  .toList(),
                            ),
                            Text(
                              rankList[i]['time'].trimLeft(),
                              style: Theme.of(context).textTheme.caption,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
