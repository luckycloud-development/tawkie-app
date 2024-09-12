import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:tawkie/pages/tickets/tickets_page.dart';

class Tickets extends StatefulWidget {

  const Tickets({super.key});

  @override
  TicketsController createState() => TicketsController();
}

class TicketsController extends State<Tickets> {
  String userId = '@honoroit:alpha.tawkie.fr';

  @override
  void initState() {
    super.initState();

    // Récupérer les rooms où cet utilisateur est présent
    List<Room> filteredRooms = getRoomsWithUser(rooms, userId);
  }

  @override
  void dispose() {

    super.dispose();
  }


  // Fonction pour obtenir les rooms où un utilisateur spécifique est présent
  List<Room> getRoomsWithUser(List<Room> rooms, String userId) {
  return rooms.where((room) => room.getParticipants().contains(userId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TicketsPage();
  }
}
