import 'package:clicli_dark/widgets/loading2load.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CWebView extends StatefulWidget {
  final String url;

  CWebView({@required this.url}) : assert(url != null);

  @override
  State<StatefulWidget> createState() => _WebView();
}

class _WebView extends State<CWebView> {
  bool isLoading = true;
  WebViewController _viewController;

  Future<bool> back() async {
    if (_viewController == null) return Future.value(true);

    final _ = await _viewController.canGoBack();
    if (_) _viewController.goBack();

    return Future.value(!_);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: back,
      child: Scaffold(
        body: SafeArea(
          top: true,
          child: Stack(
            children: <Widget>[
              WebView(
                onWebViewCreated: (_) {
                  _viewController = _;
                },
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.startsWith('http'))
                    return NavigationDecision.navigate;
                  launch(request.url);
                  return NavigationDecision.prevent;
                },
                onPageStarted: (_) {
                  isLoading = true;
                  setState(() {});
                },
                onPageFinished: (_) {
                  isLoading = false;
                  setState(() {});
                },
                gestureNavigationEnabled: false,
              ),
              Positioned(
                right: 10,
                top: 10,
                child: IconButton(
                  iconSize: 40,
                  color: Theme.of(context).accentColor,
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              if (isLoading)
                Positioned(
                  top: (MediaQuery.of(context).size.height / 2) - 75,
                  left: (MediaQuery.of(context).size.width / 2) - 75,
                  child: loadingWidget,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void toWebView(BuildContext context, {String url}) {
  Navigator.of(context).pushNamed('CliCli://webview', arguments: {'url': url});
}
