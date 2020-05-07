import 'package:clicli_dark/utils/toast_utils.dart';
import 'package:clicli_dark/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: FixedAppBar(title: Text('FAQ')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: MarkdownBody(
          data: '''
## QQ 群列表

- 可加入
  - [CliCli ⑦ 群-月色真美](https://jq.qq.com/?_wv=1027&k=5BN7gor)

- 车位已满
  - [CliCli ⑥ 群-异度侵入](https://jq.qq.com/?_wv=1027&k=5n8QbrB)

- [admin@clicli.us](mailto:admin@clicli.us)
      ''',
          onTapLink: (url) async {
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              showErrorSnackBar('打开链接失败');
            }
          },
        ),
      ),
    );
  }
}
