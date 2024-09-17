import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tawkie/widgets/platform_avatar.dart';
import 'package:tawkie/widgets/ticket_status_badge.dart';

class TicketDetailDialog extends StatelessWidget {
  final String title;
  final String platform;
  final DateTime date;
  final String status;

  const TicketDetailDialog({
    super.key,
    required this.title,
    required this.platform,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        PlatformAvatar(platform: platform),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          platform,
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.grey),
                        ),
                      ],
                    ),
                    TicketStatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 20),
                Text(formattedDate),
                const SizedBox(height: 16.0),
                SingleChildScrollView(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Positioned close button
          Positioned(
            right: -10,
            top: -10,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
