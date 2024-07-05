import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:tawkie/pages/add_bridge/add_bridge.dart';
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
    _clearCookies();
  }

  Future<void> _clearCookies() async {
    await cookieManager.clearCookies();
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
      _webViewController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState =
        Provider.of<ConnectionStateModel>(context, listen: false);

    InAppWebViewSettings settings = InAppWebViewSettings(
      userAgent:
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
      useWideViewPort: true,
      loadWithOverviewMode: true,
      supportZoom: true,
      builtInZoomControls: true,
      displayZoomControls: false,
      initialScale: 0,
      javaScriptEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
      domStorageEnabled: true,
      databaseEnabled: true,
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
        onWebViewCreated: (InAppWebViewController controller) {
          if (_isDisposed) return; // Prevent further operations if disposed
          _webViewController = controller;
        },
        onLoadStop: (InAppWebViewController controller, Uri? url) async {
          // Inject JavaScript to force desktop view for Facebook and Discord
          if (widget.network.name == "Facebook Messenger" ||
              widget.network.name == "Discord") {
            await controller.evaluateJavascript(source: """
              var meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=1024';
              document.getElementsByTagName('head')[0].appendChild(meta);
            """);
          }

          // Inject JavaScript to accept cookies automatically and not get the message when the page opens
          await controller.evaluateJavascript(source: """
            (function() {
              function clickAcceptButton() {
                var acceptButtons = document.querySelectorAll('button, input[type="button"], input[type="submit"]');
                for (var i = 0; i < acceptButtons.length; i++) {
                  var button = acceptButtons[i];
                  if (button.innerText.toLowerCase().includes('accept') ||
                      button.innerText.toLowerCase().includes('agree') ||
                      button.innerText.toLowerCase().includes('autoriser tous les cookies') ||
                      button.innerText.toLowerCase().includes('autoriser') ||
                      button.innerText.toLowerCase().includes('tous les cookies')) {
                    button.click();
                  }
                }
              }

              var observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                  clickAcceptButton();
                });
              });

              observer.observe(document.body, { childList: true, subtree: true });

              // Initial check
              clickAcceptButton();
            })();
          """);

          // Inject JavaScript for specific zoom behavior for Facebook and Discord
          if (widget.network.name == "Facebook Messenger") {
            await controller.evaluateJavascript(source: """
              (function() {
                document.body.style.zoom = "1.5";
                window.scrollTo(0, 0);
              })();
            """);
          }

          if (widget.network.name == "Discord") {
            await controller.evaluateJavascript(source: """
              (function() {
                document.body.style.zoom = "1.2";
                window.scrollTo(0, 0);
              })();
            """);
          }

          // Check the URL when the page finishes loading
          switch (widget.network.name) {
            case "Facebook Messenger":
              if (!_facebookBridgeCreated &&
                  url != null &&
                  url.toString() != widget.network.urlLogin! &&
                  url.toString().contains(widget.network.urlRedirect!)) {
                // Close the WebView
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
              }
              break;

            case "Instagram":
              if (!_instagramBridgeCreated &&
                  url != null &&
                  url.toString() != widget.network.urlLogin! &&
                  url.toString().contains(widget.network.urlRedirect!)) {
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
                    // Mark the Instagram bridge as created
                    _linkedinBridgeCreated = true;

                    await widget.controller.createBridgeLinkedin(context,
                        cookieManager, connectionState, widget.network);
                  },
                );
              }
              break;
            case "Discord":
              if (!_discordBridgeCreated &&
                  url != null &&
                  url.toString().contains(widget.network.urlRedirect!)) {
                // Close the WebView
                await _closeWebView();
                await showCustomLoadingDialog(
                  context: context,
                  future: () async {
                    // Mark the Discord bridge as created
                    _discordBridgeCreated = true;

                    await widget.controller.createBridgeDiscord(context,
                        cookieManager, connectionState, widget.network);
                  },
                );
              }
              break;
            // Other network
          }

          if (widget.network.connected == true && !_isDisposed) {
            // Close the current page
            await _closeWebView();

            // Close the current page
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
