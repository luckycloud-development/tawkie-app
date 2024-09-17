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
  List<Ticket> filteredTickets = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeTickets();
  }

  Future<void> _initializeTickets() async {
    await _getRoomsForUser();
    for (var room in filteredRooms) {
      await getTicketsFromRoom(room);
    }

    setState(() {
      loading = false;
      filteredTickets = tickets;
    });
  }

  // Filter tickets by search text
  void filterTickets(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredTickets = tickets;
      } else {
        filteredTickets = tickets
            .where((ticket) =>
            ticket.content.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
    });
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
      // Create a new room specifically for this user
      String roomId = await Matrix.of(context).client.createRoom(
            isDirect: true,
            invite: [userId],
            preset: CreateRoomPreset.trustedPrivateChat,
          );
      return roomId;
    } catch (e) {
      if (kDebugMode) {
        print("Error when creating a new room with the user $userId: $e");
      }
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

      final newTicket = Ticket(
        version: version,
        platform: platform,
        content: userMessage,
        date: DateTime.now(),
        roomId: roomId,
      );

      setState(() {
        tickets.add(newTicket);
      });

      if (kDebugMode) {
        print("Message sent in the room $roomId.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending message to room $roomId: $e");
      }
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
      if (kDebugMode) {
        print("Impossible to create a new conversation.");
      }
    }
  }

  Future<void> getTicketsFromRoom(Room room) async {
    try {
      if (tickets.any((ticket) => ticket.roomId == room.id)) {
        if (kDebugMode) {
          print(
              'Tickets for this room have already been collected: ${room.id}');
        }
        return;
      }

      final eventsResponse = await Matrix.of(context).client.getRoomEvents(
            room.id,
            Direction.b,
            limit: 50,
          );

      List<Ticket> newTickets = eventsResponse.chunk
          .map((event) {
            Map<String, Object?> content = event.content;

            String? messageBody = content['body'] as String?;
            if (messageBody != null) {
              if (kDebugMode) {
                print("Text message: $messageBody");
              }
            } else {
              if (kDebugMode) {
                print("No text found in the message");
              }
              return null;
            }

            DateTime date = event.originServerTs;

            // Create a ticket from the message and add the room id to avoid duplicates
            return Ticket.fromRoomMessage(messageBody, date)..roomId = room.id;
          })
          .where((ticket) => ticket != null)
          .cast<Ticket>()
          .toList();

      setState(() {
        // Add new tickets without duplicates
        tickets.addAll(newTickets);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving events for room ${room.id}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return TicketsPage(
        controller: this,
      );
    }
  }
}
