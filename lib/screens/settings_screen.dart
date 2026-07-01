import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../services/settings_service.dart';
import '../data/maps.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.appBar,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/screens/scales.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.36),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsPanel(
                  title: 'Choose your game style',
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      String mode = settings.selectedMode;
                      return Column(
                        children: [
                          _SettingsRadioTile(
                            title: 'Classic Mode',
                            subtitle: 'Think Nokia-style snake.',
                            value: 'Classic Mode',
                            groupValue: mode,
                            onChanged: (value) {
                              setState(() {
                                mode = value!;
                                settings.setMode(value);
                              });
                            },
                          ),
                          _SettingsRadioTile(
                            title: 'Fun Mode',
                            subtitle: 'Power-ups, boosts and surprises.',
                            value: 'Fun Mode',
                            groupValue: mode,
                            onChanged: (value) {
                              setState(() {
                                mode = value!;
                                settings.setMode(value);
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _SettingsPanel(
                  title: 'Snake speed',
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      double speed = settings.selectedSpeed;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Speed ${speed.round()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Slider(
                            value: speed,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: speed.round().toString(),
                            activeColor: AppColors.neonGreen,
                            inactiveColor: Colors.white24,
                            onChanged: (value) {
                              setState(() {
                                speed = value;
                                settings.setSpeed(value);
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _SettingsPanel(
                  title: 'Choose a map',
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      String selectedMapName = settings.selectedMapName;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gameMaps.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.82,
                            ),
                        itemBuilder: (context, index) {
                          final gameMap = gameMaps[index];
                          return _MapButton(
                            title: gameMap.name,
                            imagePath: _mapImagePath(gameMap.name),
                            isSelected: selectedMapName == gameMap.name,
                            onTap: () {
                              setState(() {
                                selectedMapName = gameMap.name;
                                settings.setMapName(gameMap.name);
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _mapImagePath(String mapName) {
  final fileName = mapName.toLowerCase().replaceAll(' ', '');
  return 'assets/images/maps/$fileName.png';
}

class _SettingsPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SettingsRadioTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _SettingsRadioTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.neonGreen.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.neonGreen : Colors.white24,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        activeColor: AppColors.neonGreen,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: const TextStyle(color: Colors.white70)),
        onChanged: onChanged,
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapButton({
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonGreen.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.neonGreen : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Expanded(child: Image.asset(imagePath, fit: BoxFit.contain)),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
