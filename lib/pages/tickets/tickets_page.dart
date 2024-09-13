import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tawkie/config/app_config.dart';
import 'package:tawkie/pages/tickets/tickets.dart';

class TicketsPage extends StatelessWidget {
  final TicketsController controller;

  const TicketsPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tickets = controller.tickets;
    return Scaffold(
      body: Stack(
        children: [
          // Main content (Ticket List)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 180.0, 16.0, 16.0),
            // Adjusting for space with AppBar
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: TicketTile(
                          title: ticket.content,
                          user: ticket.platform,
                          date: ticket.date.toString(),
                          status: 'open',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Custom AppBar with Stack
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180, // Custom height for the AppBar
              decoration: const BoxDecoration(
                color: Color(0xFF464544),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: 50,
                    right: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tickets',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.insert_drive_file,
                                size: 30, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              tickets.length.toString(),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  // Search bar inside AppBar
                  Positioned(
                    bottom: 40,
                    left: 16,
                    right: 16,
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Recherche',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Open Tickets Button (placed to overlap the AppBar)
          Positioned(
            top: 155,
            left: MediaQuery.of(context).size.width *
                0.3, // Centered horizontally
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/rooms/settings/tickets/new',
                  extra: controller,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColorLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
              child: Text('Open Tikets',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class TicketTile extends StatelessWidget {
  final String title;
  final String user;
  final String date;
  final String status;

  const TicketTile(
      {super.key,
      required this.title,
      required this.user,
      required this.date,
      required this.status});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      // Space between the tiles
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(color: Colors.grey[300]!, width: 1), // Fine border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            // Shadow color with some transparency
            spreadRadius: 1,
            // Spread the shadow a little
            blurRadius: 5,
            // How blurry the shadow should be
            offset:
                const Offset(0, 3), // Shadow position (horizontal, vertical)
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[400],
              radius: 15,
              child: Text(user[0], style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(
              'by $user',
              style: TextStyle(color: isDarkMode ? Colors.black : Colors.grey),
            )
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge for status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              // Padding inside the badge
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(20), // Rounded corners for the badge
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4), // Spacing between the badge and the date
            Text(date,
                style:
                    TextStyle(color: isDarkMode ? Colors.black : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
