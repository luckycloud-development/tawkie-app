import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:tawkie/pages/tickets/tickets_page.dart';
import 'package:tawkie/utils/platform_infos.dart';
import 'package:tawkie/widgets/matrix.dart';

import 'model/ticket_model.dart';

class Tickets extends StatefulWidget {
  const Tickets({super.key});

  @override
  TicketsController createState() => TicketsController();
}

class TicketsController extends State<Tickets> {
  String userId = '@honoroit:alpha.tawkie.fr';
  List<Room> filteredRooms = [];
  List<Ticket> tickets = [];

  @override
  void initState() {
    super.initState();
    _getRoomsForUser();
  }

  // Method to recover and filter rooms
  Future<void> _getRoomsForUser() async {
    List<Room> allRooms = Matrix.of(context).client.rooms;

    List<Room> filteredRooms = getRoomsWithUser(allRooms, userId);

    setState(() {
      this.filteredRooms = filteredRooms;
    });

    // For each filtered room, retrieve the tickets
    for (var room in filteredRooms) {
      await getTicketsFromRoom(room);
    }
  }

  // Function to obtain rooms where a specific user is present
  List<Room> getRoomsWithUser(List<Room> rooms, String userId) {
    return rooms.where((room) {
      List<User> participants = room.getParticipants();
      return participants.any((user) => user.id == userId);
    }).toList();
  }

  // Function to create a new direct chat with a user (forces creation of a new room)
  Future<String?> createNewDirectChatWithUser(String userId) async {
    try {
      // Créer une nouvelle room spécifiquement pour cet utilisateur
      String roomId = await Matrix.of(context).client.createRoom(
            isDirect: true,
            invite: [userId],
            preset: CreateRoomPreset.trustedPrivateChat,
          );
      return roomId;
    } catch (e) {
      print(
          "Erreur lors de la création d'une nouvelle room avec l'utilisateur $userId: $e");
      return null;
    }
  }

  // Function to send a message to a room
  Future<void> sendMessageToRoom({
    required String roomId,
    required String version,
    required String platform,
    required String userMessage,
  }) async {
    try {
      // Construct the content of the message to be sent
      String messageContent = """
**Version**: $version
**Plateforme**: $platform
**Message de l'utilisateur**: $userMessage
""";

      // Send the message to the specified room
      String txnId = Matrix.of(context).client.generateUniqueTransactionId();
      await Matrix.of(context).client.sendMessage(
        roomId,
        "m.room.message",
        txnId,
        {
          "msgtype": "m.text",
          "body": messageContent,
        },
      );

      print("Message envoyé dans la room $roomId.");
    } catch (e) {
      print("Erreur lors de l'envoi du message dans la room $roomId: $e");
    }
  }

  // Function to open a new ticket
  Future<void> openNewTicket({
    required String userMessage,
  }) async {
    String platform = PlatformInfos.getPlatform();
    String version = await PlatformInfos.getVersion();
    String? roomId = await createNewDirectChatWithUser(userId);

    if (kDebugMode) {
      print('platform: $platform');
      print('version: $version');
    }

    if (roomId != null) {
      await sendMessageToRoom(
        roomId: roomId,
        version: version,
        platform: platform,
        userMessage: userMessage,
      );
    } else {
      print("Impossible de créer une nouvelle conversation.");
    }
  }


  Future<void> getTicketsFromRoom(Room room) async {
    try {
      final eventsResponse = await Matrix.of(context).client.getRoomEvents(
            room.id,
            Direction.b,
            limit: 50,
          );

      // Browse events and turn them into Tickets
      List<Ticket> newTickets = eventsResponse.chunk.map((event) {
        String content = event.content['body'].toString();
        DateTime date = event.originServerTs;
        return Ticket.fromRoomMessage(content, date);
      }).toList();

      setState(() {
        tickets.addAll(newTickets);
      });
    } catch (e) {
      print(
          'Erreur lors de la récupération des événements pour la salle ${room.id}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketsPage(
      controller: this,
    );
  }
}
