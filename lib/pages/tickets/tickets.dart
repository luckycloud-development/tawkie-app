import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:tawkie/pages/tickets/tickets_page.dart';
import 'package:tawkie/widgets/matrix.dart';

class Tickets extends StatefulWidget {
  const Tickets({super.key});

  @override
  TicketsController createState() => TicketsController();
}

class TicketsController extends State<Tickets> {
  String userId = '@honoroit:alpha.tawkie.fr';
  List<Room> filteredRooms = [];

  @override
  void initState() {
    super.initState();
    _getRoomsForUser();
  }

  // Method to recover and filter roomsBug report
  Future<void> _getRoomsForUser() async {
    List<Room> allRooms = Matrix.of(context)
        .client.rooms;

    List<Room> filteredRooms = getRoomsWithUser(allRooms, userId);

    setState(() {
      this.filteredRooms = filteredRooms;
    });
  }

  // Function to obtain rooms where a specific user is present
  List<Room> getRoomsWithUser(List<Room> rooms, String userId) {
    return rooms.where((room) {
      List<User> participants = room.getParticipants();
      return participants.any((user) => user.id == userId);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TicketsPage();
  }
}
