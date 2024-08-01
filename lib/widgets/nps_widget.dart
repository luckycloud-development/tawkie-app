import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawkie/services/matomo/tracking_service.dart';

class NPSWidget extends StatefulWidget {
  const NPSWidget({super.key});

  @override
  State<NPSWidget> createState() => _NPSWidgetState();
}

class _NPSWidgetState extends State<NPSWidget> {
  int _selectedScore = -1;

  void _submitScore() {
    if (_selectedScore >= 0) {
      final trackingService = Provider.of<TrackingService>(context, listen: false);
      trackingService.trackNPSScore(_selectedScore);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Merci pour votre feedback !")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Quelle est la probabilité que vous recommandiez notre application ?"),
          const SizedBox(height: 10),
          Center(
            child: Wrap(
              spacing: 8.0,
              alignment: WrapAlignment.center,
              children: List.generate(11, (index) {
                return ChoiceChip(
                  label: Text('$index'),
                  selected: _selectedScore == index,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedScore = index;
                    });
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submitScore,
            child: const Text("Soumettre"),
          ),
        ],
      ),
    );
  }
}

void showNPSDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return const FractionallySizedBox(
        child: NPSWidget(),
      );
    },
  );
}
