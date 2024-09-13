class Ticket {
  String content; // The message or description of the problem
  String version; // Application version
  String platform; // Platform (iOS, Android, etc.)
  DateTime date; // Ticket creation date

  Ticket({
    required this.content,
    required this.version,
    required this.platform,
    required this.date,
  });

  // Factory method to create a Ticket from a room message
  factory Ticket.fromRoomMessage(String message, DateTime date) {
    final versionRegExp = RegExp(r'\*\*Version\*\*: ([^\n]+)');
    final platformRegExp = RegExp(r'\*\*Plateforme\*\*: ([^\n]+)');
    final contentRegExp = RegExp(r"\*\*Message de l'utilisateur\*\*: ([^\n]+)");

    final versionMatch = versionRegExp.firstMatch(message);
    final platformMatch = platformRegExp.firstMatch(message);
    final contentMatch = contentRegExp.firstMatch(message);

    if (versionMatch != null && platformMatch != null && contentMatch != null) {
      return Ticket(
        version: versionMatch.group(1) ?? '',
        platform: platformMatch.group(1) ?? '',
        content: contentMatch.group(1) ?? '',
        date: date,
      );
    } else {
      throw FormatException("Message format is invalid");
    }
  }
}
