import 'package:flutter/material.dart';
import 'package:tawkie/pages/tickets/tickets.dart';

class TicketCreationPage extends StatefulWidget {
  final TicketsController controller;

  const TicketCreationPage({super.key, required this.controller});

  @override
  State<TicketCreationPage> createState() => _TicketCreationPageState();
}

class _TicketCreationPageState extends State<TicketCreationPage> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Décrivez le problème',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Entrez la description du problème...',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.controller.openNewTicket(
                    userMessage: _descriptionController.text,
                  );
                },
                child: Text('Envoyer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
