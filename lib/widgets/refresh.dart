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

class _RefreshWrapperState extends State<RefreshWrapper>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;
  bool firstLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _onRefresh();
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

  Future<void> _onRefresh() async {
    _isLoading = true;
    await widget.onRefresh();
    _isLoading = false;

    if (!firstLoaded) {
      setState(() {
        firstLoaded = true;
      });
    }
  }

  bool get isLoading => _isLoading;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return firstLoaded
        ? RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: _onRefresh,
            child: widget.child,
          )
        : Center(child: CircularProgressIndicator());
  }
}
