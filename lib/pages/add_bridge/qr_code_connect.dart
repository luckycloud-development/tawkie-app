import 'package:tawkie/pages/add_bridge/add_bridge.dart';
import 'package:tawkie/pages/add_bridge/model/social_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tawkie/pages/add_bridge/model/social_network.dart';
import 'package:tawkie/pages/add_bridge/service/bot_bridge_connection.dart';
import 'package:tawkie/widgets/mxc_image.dart';
import 'package:url_launcher/url_launcher.dart';

class QRCodeConnectPage extends StatefulWidget {
  final String qrCode;
  final String code;
  final BotController botConnection;

  const QRCodeConnectPage({
    super.key,
    this.qrCode,
    this.code,
    required this.botConnection,
    required this.socialNetwork,
  });

  @override
  State<QRCodeConnectPage> createState() => _QRCodeConnectPageState();
}

class _QRCodeConnectPageState extends State<QRCodeConnectPage> {
  late Future<String> responseFuture;

  @override
  void initState() {
    super.initState();

    // To make sure the continueProcess variable is true
    // (in case you've already left the page before coming back)
    widget.botConnection.continueProcess = true;

    responseFuture = widget.botConnection.fetchData(widget.socialNetwork);
  }

  @override
  void dispose() {
    // To stop listening to received messages if the page is exited
    widget.botConnection.stopProcess();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.whatsAppQrTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QRExplanation(
                network: widget.socialNetwork,
                qrCode: widget.qrCode!,
                code: widget.code!,
              ),
              const SizedBox(height: 16),
              ResponseQRFutureBuilder(
                responseFuture: responseFuture,
                network: widget.socialNetwork,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Connection explanation section
class QRExplanation extends StatelessWidget {
  final SocialNetwork network;
  final String qrCode;
  final String? code;

  const QRExplanation(
      {super.key, required this.network, required this.qrCode, this.code});

  @override
  Widget build(BuildContext context) {
    Widget qrWidget;

    // Setting up explanatory sentences according to socialNetwork
    String qrExplainOne = "";
    String qrExplainTwo = "";
    String qrExplainTree = "";
    String qrExplainFour = "";
    String qrExplainFive = "";
    String qrExplainSix = "";
    String qrExplainSeven = "";
    String qrExplainEight = "";
    String qrExplainNine = "";

    switch (network.name) {
      case "Discord":
        qrExplainOne = L10n.of(context)!.discord_qrExplainOne;
        qrExplainTwo = L10n.of(context)!.discord_qrExplainTwo;
        qrExplainTree = L10n.of(context)!.discord_qrExplainTree;
        qrExplainFour = L10n.of(context)!.discord_qrExplainFour;
        qrExplainFive = L10n.of(context)!.discord_qrExplainFive;
        qrExplainSix = L10n.of(context)!.discord_qrExplainSix;
        qrExplainSeven = L10n.of(context)!.discord_qrExplainSeven;
        qrExplainEight = L10n.of(context)!.discord_qrExplainEight;
        qrExplainNine = L10n.of(context)!.discord_qrExplainNine;
        break;
      case "WhatsApp":
        qrExplainOne = L10n.of(context)!.whatsApp_qrExplainOne;
        qrExplainTwo = L10n.of(context)!.whatsApp_qrExplainTwo;
        qrExplainTree = L10n.of(context)!.whatsApp_qrExplainTree;
        qrExplainFour = L10n.of(context)!.whatsApp_qrExplainFour;
        qrExplainFive = L10n.of(context)!.whatsApp_qrExplainFive;
        qrExplainSix = L10n.of(context)!.whatsApp_qrExplainSix;
        qrExplainSeven = L10n.of(context)!.whatsApp_qrExplainSeven;
        qrExplainEight = L10n.of(context)!.whatsApp_qrExplainEight;
        qrExplainNine = L10n.of(context)!.whatsApp_qrExplainNine;
        break;
    }

    print(qrCode);

    // Setting up the QR code shape according to SocialNetwork
    switch (network.name) {
      case "Discord":
        qrWidget = MxcImage(
          uri: Uri.parse(qrCode),
          width: 500,
          height: 500,
          fit: BoxFit.cover,
        );

        break;
      case "WhatsApp":
        qrWidget = QrImageView(
          data: qrCode,
          version: QrVersions.auto,
          size: 300,
        );
        break;
      default:
        qrWidget = QrImageView(
          data: qrCode,
          version: QrVersions.auto,
          size: 300,
        );
        break;
    }

    return Column(
      children: [
        Text(
          L10n.of(context)!.whatsAppQrExplainOne,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          L10n.of(context)!.whatsAppQrExplainTwo,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          L10n.of(context)!.whatsAppQrExplainTree,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          L10n.of(context)!.whatsAppQrExplainFour,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          L10n.of(context)!.whatsAppQrExplainFive,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        code != null
            ? GestureDetector(
                onTap: () {
                  switch (network.name) {
                    case "Discord":
                      launchUrl(Uri.parse(code!));
                      break;
                    case "WhatsApp":
                      Clipboard.setData(ClipboardData(text: code!));

                      final SnackBar snackBar = SnackBar(
                          content: Text(
                        L10n.of(context)!.codeCopy,
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      break;
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    code!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
              )
            : Container(),
        const SizedBox(height: 8),
        const Divider(
          color: Colors.grey,
          height: 20,
        ),
        Text(
          L10n.of(context)!.whatsAppQrExplainSix,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(L10n.of(context)!.whatsAppQrExplainSeven,
                style: const TextStyle(
                  fontSize: 16,
                )),
            Text(
              L10n.of(context)!.whatsAppQrExplainEight,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          L10n.of(context)!.whatsAppQrExplainTen,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        qrWidget, //Location of previously built QR code
      ],
    );
  }
}

// FutureBuilder part listening to responses in real time
class ResponseQRFutureBuilder extends StatelessWidget {
  final Future<String> responseFuture;
  final SocialNetwork network;

  const ResponseQRFutureBuilder({
    super.key,
    required this.responseFuture,
    required this.network,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: responseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('${L10n.of(context)!.err_} ${snapshot.error}');
        } else {
          return buildAlertDialog(context, snapshot.data as String, network);
        }
      },
    );
  }

// AlertDialog displayed when an error or success occurs, listening directly to the response
  Widget buildAlertDialog(
      BuildContext context, String result, SocialNetwork network) {
    if (result == "success") {
      Future.microtask(() {
        // Call function to display success dialog box
        showSuccessDialog(context, network);
      });
    } else if (result == "loginTimedOut") {
      Future.microtask(() {
        // Call the function to display the "Elapsed time" dialog box
        showTimeoutDialog(context);
      });
    }

    return Container();
  }

// showDialog of a success message when connecting and updating socialNetwork
  Future<void> showSuccessDialog(
      BuildContext context, SocialNetwork network) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            L10n.of(context)!.wellDone,
          ),
          content: Text(
            L10n.of(context)!.whatsAppConnectedText,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // SocialNetwork network update
                SocialNetworkManager.socialNetworks
                    .firstWhere((element) => element.name == "WhatsApp")
                    .connected = true;

                Navigator.of(context).pop();
                if (network.name != "Discord") {
                  // Goes back twice (closes current and previous pages)
                  Navigator.pop(context, true);
                }
              },
              child: Text(
                L10n.of(context)!.ok,
              ),
            ),
          ],
        );
      },
    );
  }

// showDialog of elapsed time error message
  Future<void> showTimeoutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            L10n.of(context)!.errElapsedTime,
          ),
          content: Text(
            L10n.of(context)!.errExpiredSession,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (network.name != "Discord") {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                L10n.of(context)!.ok,
              ),
            ),
          ],
        );
      },
    );
  }
}
