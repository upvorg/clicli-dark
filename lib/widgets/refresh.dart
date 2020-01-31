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
  bool isLoadMore = false;

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
    isLoadMore = true;
    setState(() {});

    _isLoading = true;
    await widget.onLoadMore();
    _isLoading = false;
    isLoadMore = false;
  }

  Future<void> _onRefresh() async {
    if (isLoading) return;
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
            child: Stack(
              children: <Widget>[
                widget.child,
                if (isLoadMore)
                  Positioned(
                      top: 15,
                      left: MediaQuery.of(context).size.width / 2 - 17.5,
                      child: Opacity(
                        opacity: isLoadMore ? 1 : 0,
                        child: Container(
                          width: 35,
                          height: 35,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100))),
                          child: SizedBox(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ))
              ],
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}
