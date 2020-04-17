import 'package:clicli_dark/widgets/loading2load.dart';
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
  bool hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _onRefresh();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.maxScrollExtent -
              widget.scrollController.position.pixels <=
          300) {
        if (!_isLoading) _onLoadMore();
      }
    });
  }

  Future<void> _onLoadMore() async {
    isLoadMore = true;
    setState(() {});
    try {
      _isLoading = true;
      await widget.onLoadMore();
      _isLoading = false;
      isLoadMore = false;
    } catch (e) {
      setState(() {
        _isLoading = false;
        isLoadMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    if (isLoading) return;
    _isLoading = true;

    try {
      if (hasError) {
        setState(() {
          hasError = false;
        });
      }
      await widget.onRefresh();
      _isLoading = false;
      if (!firstLoaded) firstLoaded = true;
      setState(() {});
    } catch (e) {
      setState(() {
        hasError = true;
        _isLoading = false;
        firstLoaded = false;
      });
    }
  }

  bool get isLoading => _isLoading;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: _onRefresh,
      child: hasError
          ? errorWidget(retryFn: _onRefresh)
          : firstLoaded
              ? Stack(
                  children: <Widget>[
                    widget.child,
                    if (isLoadMore)
                      Positioned(
                          top: 15,
                          left: MediaQuery.of(context).size.width / 2 - 20,
                          child: AnimatedOpacity(
                            opacity: isLoadMore ? 1 : 0,
                            duration: Duration(milliseconds: 300),
                            child: Container(
                              width: 40,
                              height: 40,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(1, 1),
                                        blurRadius: 2)
                                  ]),
                              child: SizedBox(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          ))
                  ],
                )
              : Center(child: loadingWidget),
    );
  }
}
