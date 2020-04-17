import 'package:flutter/material.dart';

class FixedAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color backgroundColor;
  final double elevation;

  const FixedAppBar(
      {Key key,
      this.automaticallyImplyLeading = true,
      this.actions,
      this.title,
      this.centerTitle = true,
      this.backgroundColor,
      this.elevation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _title = title;
    if (centerTitle) {
      _title = Center(child: _title);
    }
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        boxShadow: null,
        color: backgroundColor ?? Theme.of(context).appBarTheme.color,
      ),
      child: Row(
        children: <Widget>[
          if (automaticallyImplyLeading && Navigator.of(context).canPop())
            BackButton(),
          Expanded(child: _title),
          if (automaticallyImplyLeading &&
              Navigator.of(context).canPop() &&
              actions == null)
            SizedBox.fromSize(size: Size.square(56.0)),
          if (actions != null) ...actions,
        ],
      ),
    );
  }
}

class HomeStackTitleAppbar extends StatelessWidget {
  final String title;

  HomeStackTitleAppbar(this.title);

  @override
  Widget build(BuildContext context) {
    final textStyle =
        TextStyle(color: Theme.of(context).accentColor, fontSize: 24);
    return FixedAppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[Tab(child: Text(title, style: textStyle))],
        ),
      ),
    );
  }
}
