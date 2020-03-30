import 'package:flutter/material.dart';

final loadingWidget = Image.asset(
  'assets/loading.gif',
  width: 150,
  height: 150,
);

class Loading2Load extends StatefulWidget {
  Loading2Load({@required this.child, @required this.load});

  final Function load;
  final Widget child;
  @override
  State<StatefulWidget> createState() => _Loading2LoadState();
}

class _Loading2LoadState extends State<Loading2Load> {
  bool loaded = false;
  bool hasError = false;

  @override
  void initState() {
    load();
    super.initState();
  }

  load() async {
    try {
      if (hasError) {
        setState(() {
          hasError = false;
        });
      }
      await widget.load();
      setState(() {
        loaded = true;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        loaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return hasError
        ? Container(
            child: IconButton(
              icon: Image.asset(
                'assets/error.png',
                width: 150,
                height: 150,
              ),
              onPressed: load,
            ),
          )
        : loaded ? widget.child : Center(child: loadingWidget);
  }
}
