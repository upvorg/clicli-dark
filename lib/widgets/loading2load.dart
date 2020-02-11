import 'package:flutter/material.dart';

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
              icon: Icon(Icons.refresh),
              onPressed: load,
            ),
          )
        : loaded ? widget.child : Center(child: CircularProgressIndicator());
  }
}
