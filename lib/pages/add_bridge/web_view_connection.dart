import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:tawkie/pages/add_bridge/add_bridge.dart';
import 'package:tawkie/utils/bridge_utils.dart';
import 'package:tawkie/utils/webview_scripts.dart';
import 'package:tawkie/widgets/future_loading_dialog_custom.dart';
import 'package:tawkie/widgets/notifier_state.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

import 'model/social_network.dart';

class WebViewConnection extends StatefulWidget {
  final BotController controller;
  final SocialNetwork network;
  final Function(bool success) onConnectionResult; // Callback function

  const WebViewConnection({
    super.key,
    required this.controller,
    required this.network,
    required this.onConnectionResult,
  });

  @override
  State<WebViewConnection> createState() => _WebViewConnectionState();
}

class _WebViewConnectionState extends State<WebViewConnection> {
  InAppWebViewController? _webViewController;
  final cookieManager = WebviewCookieManager();
  bool _isDisposed = false; // Variable to track widget status
  bool _facebookBridgeCreated =
      false; // Variable to track if the Facebook bridge has been created
  bool _instagramBridgeCreated =
      false; // Variable to track if the Instagram bridge has been created
  bool _linkedinBridgeCreated =
      false; // Variable to track if the Linkedin bridge has been created
  bool _discordBridgeCreated =
      false; // Variable to track if the Discord bridge has been created

  @override
  void initState() {
    super.initState();
    _clearCookiesAndData();
  }

  Future<void> _clearCookiesAndData() async {
    await cookieManager.clearCookies();
    if (_webViewController != null) {
      await _webViewController!
          .evaluateJavascript(source: clearCookiesAndStorage)
          .then((result) {
        // Handle the result if necessary
      }).catchError((error) {
        // Handle the error if necessary
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _closeWebView() async {
    if (_webViewController != null && mounted) {
      await _webViewController!
          .loadUrl(urlRequest: URLRequest(url: WebUri('about:blank')));
      _webViewController!.dispose();
      _webViewController = null;
    }
  }

  // Whether the social network is FB Messenger
  bool _isMessenger() {
    return widget.network.name == 'Facebook Messenger';
  }

  // Add custom style to the login page to make it more user-friendly
  Future<void> _addCustomStyle() async {
    final socialNetwork = getSocialNetworkEnum(widget.network.name);
    if (_webViewController != null) {
      switch (socialNetwork) {
        case SocialNetworkEnum.FacebookMessenger:
          await _webViewController!.evaluateJavascript(source: getCombinedScriptMessenger());
          break;
        case SocialNetworkEnum.Instagram:
          await _webViewController!.evaluateJavascript(source: getCombinedScriptInstagram());
          break;
        case SocialNetworkEnum.Linkedin:
          await _webViewController!.evaluateJavascript(source: getCombinedScriptLinkedin());
          break;
        default:
          return; // Or throw an exception if you prefer
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState =
        Provider.of<ConnectionStateModel>(context, listen: false);

    // Set custom user agent to increase credibility and *confusion*
    // Messenger will not display the login fields if we use a mobile user-agent
    final userAgent = _isMessenger()
        // Chrome on Windows 10
        ? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'
        // Chrome on Galaxy S9
        : 'Mozilla/5.0 (Linux; Android 14; SM-G960U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.6478.122 Mobile Safari/537.36';

    final InAppWebViewSettings settings = InAppWebViewSettings(
      userAgent: userAgent,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.network.name,
        ),
        centerTitle: true,
      ),
      body: InAppWebView(
        initialSettings: settings,
        initialUrlRequest: URLRequest(
          url: WebUri(widget.network.urlLogin!),
        ),
        onWebViewCreated: (InAppWebViewController controller) async {
          if (_isDisposed) return; // Prevent further operations if disposed
          _webViewController = controller;
          await _clearCookiesAndData();
        },
        onLoadStop: (InAppWebViewController controller, Uri? url) async {
          // Check the URL when the page finishes loading
          switch (widget.network.name) {
            case "Facebook Messenger":
              final successfullyRedirected = !_facebookBridgeCreated &&
                  url != null &&
                  url.toString() != widget.network.urlLogin! &&
                  url.toString().contains(widget.network.urlRedirect!);

              if (successfullyRedirected) {
                await _closeWebView();

                await showCustomLoadingDialog(
                  context: context,
                  future: () async {
                    // Mark the Facebook bridge as created
                    _facebookBridgeCreated = true;

                    await widget.controller.createBridgeMeta(context,
                        cookieManager, connectionState, widget.network);
                  },
                );
              } else {
                // assume login page
                await _addCustomStyle();
              }
              break;

            case "Instagram":
              final successfullyRedirected = !_instagramBridgeCreated &&
                  url != null &&
                  url.toString() != widget.network.urlLogin! &&
                  url.toString().contains(widget.network.urlRedirect!);

              if (successfullyRedirected) {
                // Close the WebView
                await _closeWebView();
                await showCustomLoadingDialog(
                  context: context,
                  future: () async {
                    // Mark the Instagram bridge as created
                    _instagramBridgeCreated = true;

                    await widget.controller.createBridgeMeta(context,
                        cookieManager, connectionState, widget.network);
                  },
                );
              }else{
                await _addCustomStyle();
              }
              break;

            case "Linkedin":
              if (!_linkedinBridgeCreated &&
                  url != null &&
                  url.toString().contains(widget.network.urlRedirect!)) {
                // Close the WebView
                await _closeWebView();
                await showCustomLoadingDialog(
                  context: context,
                  future: () async {
                    // Mark the Linkedin bridge as created
                    _linkedinBridgeCreated = true;

                    await widget.controller.createBridgeLinkedin(context,
                        cookieManager, connectionState, widget.network);
                  },
                );
              } else {
                await _addCustomStyle();
              }
              break;
          }

          if (widget.network.connected && !_isDisposed) {
            // Close the current page
            await _closeWebView();

            // Close the current page
            Navigator.pop(context);
          }
        },
        onReceivedHttpError: (InAppWebViewController controller,
            WebResourceRequest request, WebResourceResponse response) async {
          switch (widget.network.name) {
            case "Discord":
              String? authorizationHeaderValue = widget.controller
                  .extractAuthorizationHeader(request.headers!);

              if (authorizationHeaderValue != null) {
                if (!_discordBridgeCreated) {
                  // Close the WebView
                  await _closeWebView();
                }
                await showCustomLoadingDialog(
                  context: context,
                  future: () async {
                    await widget.controller.createBridgeDiscord(
                        context,
                        cookieManager,
                        connectionState,
                        widget.network,
                        authorizationHeaderValue);
                  },
                );
                // Close the current page
                Navigator.pop(context);
              }
              break;
            // Other network
          }
        },
      ),
    );
  }
}
