

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:tawkie/pages/add_bridge/add_bridge_body.dart';
import 'package:tawkie/pages/add_bridge/service/hostname.dart';
import 'package:tawkie/pages/add_bridge/service/reg_exp_pattern.dart';
import 'package:tawkie/widgets/matrix.dart';

import 'model/social_network.dart';

class AddBridge extends StatefulWidget {
  const AddBridge({super.key});

  @override
  BotController createState() => BotController();
}

class BotController extends State<AddBridge> {
  String? messageError;
  bool loading = true;
  bool continueProcess = true;

  late Client client;
  late String hostname;

  List<SocialNetwork> socialNetworks = SocialNetworkManager.socialNetworks;

  @override
  void initState() {
    super.initState();
    matrixInit();
    handleRefresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void matrixInit() {
    client = Matrix.of(context).client;
    final String fullUrl = client.homeserver!.host;
    hostname = extractHostName(fullUrl);
  }

  Future<void> handleRefresh() async {
    setState(() {
      // Reset loading values to their original state
      for (final network in socialNetworks) {
        network.loading = true;
        network.connected = false;
        network.error = false;
      }
    });

    // Execute pingSocialNetwork for all social networks in parallel
    await Future.wait(socialNetworks.map((network) {
      return pingSocialNetwork(network);
    }));
  }

  Future<void> pingSocialNetwork(SocialNetwork socialNetwork) async {
    final String botUserId = '${socialNetwork.chatBot}$hostname';

    // Messages to spot when we're online
    RegExp? onlineMatch;

    // Messages to spot when we're not online
    RegExp? notLoggedMatch;
    RegExp? mQTTNotMatch;

    switch (socialNetwork.name) {
      case "WhatsApp":
        onlineMatch = PingPatterns.whatsAppOnlineMatch;
        notLoggedMatch = PingPatterns.whatsAppNotLoggedMatch;
        mQTTNotMatch = PingPatterns.whatsAppLoggedButNotConnectedMatch;
        break;
      case "Facebook Messenger":
        onlineMatch = PingPatterns.facebookOnlineMatch;
        notLoggedMatch = PingPatterns.facebookNotLoggedMatch;
        break;
      case "Instagram":
        onlineMatch = PingPatterns.instagramOnlineMatch;
        notLoggedMatch = PingPatterns.instagramNotLoggedMatch;
        break;
      default:
        throw Exception("Unsupported social network: ${socialNetwork.name}");
    }

    // Add a direct chat with the bot (if you haven't already)
    String? directChat = client.getDirectChatFromUserId(botUserId);
    directChat ??= await client.startDirectChat(botUserId);

    final Room? roomBot = client.getRoomById(directChat);

    // Send the "ping" message to the bot
    try {
      await roomBot?.sendTextEvent("ping");
    } catch (error) {
      Logs().i('Error: $error');
      setState(() {
        socialNetwork.setError(true);
      });
    }

    await Future.delayed(const Duration(seconds: 2)); // Wait sec

    String result = ''; // Variable to track the result of the connection

    // Variable for loop limit
    const int maxIterations = 5;
    int currentIteration = 0;

    while (continueProcess && currentIteration < maxIterations) {
      // To take the latest message
      final GetRoomEventsResponse response = await client.getRoomEvents(
        directChat,
        Direction.b, // To get the latest messages
        limit: 1, // Number of messages to obtain
      );

      final List<MatrixEvent> latestMessages = response.chunk ?? [];

      if (latestMessages.isNotEmpty) {
        final String latestMessage =
            latestMessages.first.content['body'].toString() ?? '';

        // To find out if we're connected
        if (onlineMatch.hasMatch(latestMessage)) {
          Logs().v("You're logged to ${socialNetwork.name}");

          setState(() {
            socialNetwork.updateConnectionResult(true);
            socialNetwork.setError(false);
          });

          break; // Exit the loop if the bridge is connected
        }
        if (notLoggedMatch.hasMatch(latestMessage) == true) {
          Logs().v('Not connected to ${socialNetwork.name}');

          setState(() {
            socialNetwork.updateConnectionResult(false);
            socialNetwork.setError(false);
          });

          break; // Exit the loop if the bridge is disconnected
        } else if (mQTTNotMatch?.hasMatch(latestMessage) == true) {
          String eventToSend;

          switch (socialNetwork.name) {
            case "WhatsApp":
              eventToSend = "reconnect";
              break;
            default:
              eventToSend = "connect";
              break;
          }

          await roomBot?.sendTextEvent(eventToSend);

          await Future.delayed(const Duration(seconds: 3)); // Wait sec
        } else {
          // If no new message is received from the bot, we send back a ping
          // Or no expected answer is found
          await roomBot?.sendTextEvent("ping");
          await Future.delayed(const Duration(seconds: 2)); // Wait sec
        }
      }
      currentIteration++;
    }

    if (currentIteration == maxIterations) {
      Logs().v(
          "Maximum iterations reached, setting result to 'error to ${socialNetwork.name}'");

      setState(() {
        socialNetwork.setError(true);
      });
    } else if (!continueProcess) {
      Logs().v(('ping stopping'));
      result = 'stop';
    }
  }


  @override
  Widget build(BuildContext context) => AddBridgeBody(controller: this);
}
