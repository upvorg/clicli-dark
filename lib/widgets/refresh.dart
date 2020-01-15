import 'package:flutter/material.dart';

class RefreshPage extends StatefulWidget {
  final Widget child;
  final RefreshCallback onRefresh;

  const RefreshPage({
    Key key,
    @required this.child,
    @required this.onRefresh,
  })  : assert(child != null),
        assert(onRefresh != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<RefreshPage> {
  @override
  Widget build(BuildContext context) {
    return null;
  }
}
