import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tawkie/main.dart';
import 'package:tawkie/utils/client_manager.dart';
import 'package:tawkie/widgets/future_loading_dialog_custom.dart';
import 'package:tawkie/widgets/notifier_state.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'model/social_network.dart';
import 'service/bot_bridge_connection.dart';

class WebViewConnection extends StatefulWidget {
  final BotBridgeConnection botBridgeConnection;
  final SocialNetwork network;
  final Function(bool success) onConnectionResult; // Callback function

  const WebViewConnection({
    super.key,
    required this.botBridgeConnection,
    required this.network,
    required this.onConnectionResult,
  });

  @override
  State<WebViewConnection> createState() => _WebViewConnectionState();
}

class _WebViewConnectionState extends State<WebViewConnection> {
  InAppWebViewController? _webViewController;
  final cookieManager = WebviewCookieManager();
  String? authToken;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState =
        Provider.of<ConnectionStateModel>(context, listen: false);

    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(widget.network.urlLogin!),
        ),
        onWebViewCreated: (InAppWebViewController controller) async {
          _webViewController = controller;

          // Cache reset
          await _webViewController?.clearCache();
        },
        onReceivedHttpError: (InAppWebViewController controller,
            WebResourceRequest request, WebResourceResponse response) async {
          if (widget.network.name == 'Discord') {
            String result =
                ""; // Variable to store the result of the connection

            String headers = request.headers.toString();
            RegExp regExp = RegExp(r'Authorization: ([^,]+)');
            Match? match = regExp.firstMatch(headers);

            String? authorizationHeaderValue;

            if (match != null && match.groupCount > 0) {
              authorizationHeaderValue = match.group(1)!;
              print('Authorization header value: $authorizationHeaderValue');
            }

            if (authorizationHeaderValue != null) {
              await showCustomLoadingDialog(
                context: context,
                future: () async {
                  result = await widget.botBridgeConnection.createBridgeDiscord(
                      context,
                      cookieManager,
                      connectionState,
                      widget.network,
                      authorizationHeaderValue!);
                },
              );

              if (result == "success") {
                // Close the current page
                Navigator.pop(context);

                // Close the current page
                if (_webViewController != null) {
                  _webViewController!.dispose();
                }

                // Call callback function with success result
                widget.onConnectionResult(true);
              }
            }
          }
        },
      ),
    );
  }
}
