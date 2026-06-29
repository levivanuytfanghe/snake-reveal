import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static double selectedSpeed = 3;
  static String selectedMode = 'Classic Mode';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instellingen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Choose your game style:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                String mode = selectedMode;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Classic Mode (think Nokia-style)'),
                      value: 'Classic Mode',
                      groupValue: mode,
                      onChanged: (value) {
                        setState(() {
                          mode = value!;
                          selectedMode = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Fun Mode (think powerups)'),
                      value: 'Fun Mode',
                      groupValue: mode,
                      onChanged: (value) {
                        setState(() {
                          mode = value!;
                          selectedMode = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            const Text(
              'Kies een map:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(5, (index) {
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),
            const Text(
              'Snelheid van de slang:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                double speed = selectedSpeed;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: speed,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: speed.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          speed = value;
                          selectedSpeed = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),

            const Text(
              'Thema:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Terug'),
            ),
          ],
        ),
      ),
    );
  }
}
