import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:tawkie/pages/chat/events/message_content.dart';
import 'package:url_launcher/url_launcher.dart';

class MergedMessageContent extends StatelessWidget {
  final List<Event> events;

  const MergedMessageContent(this.events, {super.key});

  @override
  Widget build(BuildContext context) {
    // Ignore the first and last events in the list
    final List<Event> eventsToDisplay =
        events.sublist(1, events.length - 1).reversed.toList();
    final Event firstEvent = events.first;

    // Check if the message contains a URL using a regular expression
    final bool containsUrl = hasUrl(firstEvent.text);

    // Extract the URL from the text, if any
    final String? urlFromText =
        containsUrl ? extractUrlFromText(firstEvent.text) : null;

    // Check if the text contains only a URL
    final bool containsUrlOnly = containsUrl && urlFromText == firstEvent.text;

    return Column(
      children: [
        // Display the remaining events in the group
        ...eventsToDisplay.map(
          (event) => MessageContent(
            event,
            textColor: Colors.black,
            borderRadius: BorderRadius.zero,
          ),
        ),
        // Display the text only if it's not just a URL
        if (!containsUrlOnly)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              firstEvent.text,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        // Display the first event
        SizedBox(
          width: double.infinity,
          child: containsUrl
              ? ElevatedButton(
                  onPressed: () {
                    // Handle button click
                    openUrl(Uri.parse(
                        !containsUrlOnly ? urlFromText! : firstEvent.text));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                  ),
                  child: Text(
                    L10n.of(context)!.link_openPost,
                  ),
                )
              : Container(), // If no URL, don't display anything
        ),
      ],
    );
  }

  // Function to open URL
  void openUrl(Uri url) async {
    final String urlString = url.toString();
    try {
      await launchUrl(Uri.parse(urlString), mode: LaunchMode.inAppBrowserView);
    } catch (e) {
      // Handle the exception
      Logs().i('Could not launch $urlString: $e');
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

  // Function to extract the URL from the text, if any
  String? extractUrlFromText(String text) {
    final RegExp urlRegex = RegExp(
      r'https?://(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z]+)*(?:/[^\s]*)?',
    );
    final Match? match = urlRegex.firstMatch(text);
    return match?.group(0);
  }
}
