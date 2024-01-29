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

    // Check if the message contains a URL using a regular expression
    final bool containsUrl = hasUrl(firstEvent.text);

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
          child: containsUrl
              ? ElevatedButton(
                  onPressed: () {
                    // Handle button click
                    openUrl(url);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                  ),
                  child: Text('Go to post'),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    firstEvent.text,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
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

  // Function to check if a string contains a URL using a regular expression
  bool hasUrl(String text) {
    // Regular expression for matching URLs
    final RegExp urlRegex = RegExp(
      r'https?://(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z]+)*(?:/[^\s]*)?',
    );

    return urlRegex.hasMatch(text);
  }
}
