import 'package:flutter/material.dart';

class RefreshWrapper extends StatefulWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  final RefreshCallback onLoadMore;
  final ScrollController scrollController;

  const RefreshWrapper({
    Key key,
    @required this.child,
    @required this.onRefresh,
    @required this.onLoadMore,
    @required this.scrollController,
  })  : assert(child != null),
        assert(onRefresh != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RefreshWrapperState();
  }
}

class _RefreshWrapperState extends State<RefreshWrapper> {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent) {
        if (!_isLoading) _onLoadMore();
      }
    });
  }

  Future<void> _onLoadMore() async {
    _isLoading = true;
    await widget.onLoadMore();
    _isLoading = false;
  }

  bool get isLoading => _isLoading;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: widget.onRefresh,
      child: widget.child,
    );
  }
}
