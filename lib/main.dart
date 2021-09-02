import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MaterialApp(home: SainikPublicSchool()));
}

class SainikPublicSchool extends StatefulWidget {
  @override
  _SainikPublicSchoolState createState() => _SainikPublicSchoolState();
}

class _SainikPublicSchoolState extends State<SainikPublicSchool> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  late WebViewController controller;

  Future<void> getPermessions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.accessMediaLocation,
      Permission.storage,
    ].request();

    if (statuses[Permission.accessMediaLocation] == PermissionStatus.denied) {
      Permission.accessMediaLocation.request();
    } else if (await Permission.accessMediaLocation.isPermanentlyDenied)
      openAppSettings();
    if (statuses[Permission.storage] == PermissionStatus.denied) {
      Permission.storage.request();
    } else if (await Permission.storage.isPermanentlyDenied) openAppSettings();
  }

  @override
  void initState() {
    super.initState();
    getPermessions();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
          child: Builder(
            builder: (BuildContext context) {
              return WebView(
                initialUrl: 'https://sainikpublicschoolbahadurgarh.com/',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                  controller = webViewController;
                },
                javascriptChannels: <JavascriptChannel>{
                  _toasterJavascriptChannel(context),
                },
                navigationDelegate: (NavigationRequest request) async {
                  if (request.url.startsWith('https://us05web.zoom.us')) {
                    await launch(request.url);
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
                gestureNavigationEnabled: true,
              );
            },
          ),
        ),
      ),
      onWillPop: () async {
        return await navigationController();
      },
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      },
    );
  }

  Future<bool> navigationController() async {
    final String? url = await controller.currentUrl();
    print(url);
    if (url == 'https://sainikpublicschoolbahadurgarh.com/') {
      return true;
    } else {
      controller.goBack();
      return false;
    }
  }
}
