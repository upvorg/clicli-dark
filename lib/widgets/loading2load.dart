import 'package:flutter/material.dart';

final loadingWidget = Image.asset(
  'assets/loading.gif',
  width: 150,
  height: 150,
);

Widget errorWidget({Function retryFn}) {
  return Center(
    child: InkWell(
      child: Image.asset(
        'assets/error.png',
        width: 150,
        height: 150,
      ),
      onTap: retryFn,
    ),
  );
}

typedef _AsyncWidgetBuilder<T> = Widget Function(
    BuildContext context, T snapshot);

class Loading2Load<T> extends StatelessWidget {
  Loading2Load({@required this.builder, @required this.load});

  final Future<T> Function() load;
  final _AsyncWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: load(),
      builder: (_, __) {
        switch (__.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(child: loadingWidget);
          case ConnectionState.done:
            if (__.hasError) return errorWidget(retryFn: load);
            return builder(_, __.data);
          default:
            return Container();
        }
      },
    );
  }
}

class KLoading2Load extends StatefulWidget {
  KLoading2Load({@required this.child, @required this.load});

  final Function load;
  final Widget child;
  @override
  State<StatefulWidget> createState() => _KLoading2LoadState();
}

class _KLoading2LoadState extends State<KLoading2Load> {
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
        ? Center(
            child: InkWell(
              child: Image.asset(
                'assets/error.png',
                width: 150,
                height: 150,
              ),
              onTap: load,
            ),
          )
        : loaded ? widget.child : Center(child: loadingWidget);
  }
}
