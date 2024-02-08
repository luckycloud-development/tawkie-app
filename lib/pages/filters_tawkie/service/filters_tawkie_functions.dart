import 'package:matrix/matrix.dart';

Stream<Map<String, Tag>> getAllRoomTags(Client client) async* {
  // Récupère toutes les rooms du client
  final rooms = client.getRooms();

  for (final room in rooms) {
    // Récupère les tags de chaque room
    final tags = room.tags;
    yield tags;
  }
}

Future<void> addTagToRoom(Room room, String tag) async {
  try {
    // Ajouter le tag à la room
    await room.addTag(tag);
    print('Tag ajouté avec succès à la Room.');
  } catch (e) {
    print('Erreur lors de l\'ajout du tag à la Room: $e');
  }
}