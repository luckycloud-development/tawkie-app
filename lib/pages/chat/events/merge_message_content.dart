import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:tawkie/pages/chat/events/message_content.dart';

class MergeMessageContent extends StatelessWidget {
  final List<Event> events;

  const MergeMessageContent(this.events, {super.key});

  @override
  Widget build(BuildContext context) {
    // Logic to display events in the group
    // To display each event individually via MessageContent.
    return Column(
      children: events
          .map((event) => MessageContent(
                event,
                textColor: Colors.blue,
                borderRadius: BorderRadius.zero,
              ))
          .toList()
          .reversed
          .toList(),
    );
  }
}
