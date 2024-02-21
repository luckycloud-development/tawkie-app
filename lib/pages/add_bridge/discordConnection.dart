import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:tawkie/pages/add_bridge/model/social_network.dart';
import 'package:tawkie/pages/add_bridge/qr_code_connect.dart';
import 'package:tawkie/pages/add_bridge/service/bot_bridge_connection.dart';

import 'error_message_dialog.dart';

class DiscordConnection extends StatelessWidget {
  final BotBridgeConnection botConnection;
  final SocialNetwork network;

  final Completer<bool> completer = Completer<bool>();

  DiscordConnection(
      {super.key, required this.botConnection, required this.network});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.discord_connectionTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(L10n.of(context)!.discord_connectToQrCode),
            onTap: () async {
              try {
                DiscordResult? discordResult;

                await showFutureLoadingDialog(
                  context: context,
                  future: () async {
                    discordResult = await botConnection
                        .createBridgeDiscordQRCode(context, network);
                  },
                );

                if (discordResult != null) {
                  // ShowDialog for code and QR Code login
                  final bool success = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodeConnectPage(
                            qrCode: discordResult!.qrCode!,
                            code: discordResult!.urlLink!,
                            botConnection: botConnection,
                            socialNetwork: network,
                          ),
                        ),
                      ) ??
                      false;
                }
              } catch (e) {
                Navigator.of(context).pop();
                //To view other catch-related errors
                showCatchErrorDialog(context, e);
              }
            },
          ),
          ListTile(
            title: Text(L10n.of(context)!.discord_connectUsernamePassword),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
