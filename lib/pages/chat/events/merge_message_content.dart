import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:tawkie/pages/chat/events/message_content.dart';
import 'package:url_launcher/url_launcher.dart';

class MergeMessageContent extends StatelessWidget {
  final List<Event> events;

  const MergeMessageContent(this.events, {super.key});

  @override
  Widget build(BuildContext context) {
    // Ignore the first and last events in the list
    final List<Event> eventsToDisplay =
        events.sublist(1, events.length - 1).reversed.toList();
    final Event firstEvent = events.first;
    final Uri url =
        Uri.parse(firstEvent.text); // Uri.parse to convert the string to Uri

    return Column(
      children: [
        // Display the remaining events in the group
        ...eventsToDisplay.map(
          (event) => MessageContent(
            event,
            textColor: Colors.blue,
            borderRadius: BorderRadius.zero,
          ),
        ),
        // Display the first event as a button with the extracted link
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle button click
              openUrl(url);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
            ),
            child: Text('Go to post'),
          ),
        ),
      ],
    );
  }

  // Function to open URL
  void openUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
