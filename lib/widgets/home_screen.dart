import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onStartGame;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenGallery;
  final bool hasNewUnlock;

  const HomeScreen({
    super.key,
    required this.onStartGame,
    required this.onOpenSettings,
    required this.onOpenGallery,
    this.hasNewUnlock = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/screens/slang_op_paars.png'),
          fit: BoxFit.cover,
        ),
      ),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.10),
          Text(
            'Snake Reveal',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4beb44),
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.07),
          _buildMenuButton(context, 'Start new game', onStartGame),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          _buildMenuButton(context, 'Settings', onOpenSettings),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          _buildMenuButton(
            context,
            'Reveal Gallery',
            onOpenGallery,
            showNewDot: hasNewUnlock,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'a game by Rednose Digital',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    VoidCallback onPressed, {
    bool showNewDot = false,
  }) {
    final double fontSize = MediaQuery.of(context).size.width * 0.055;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        side: const BorderSide(color: Color(0xFF4beb44), width: 2),
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.08,
          vertical: MediaQuery.of(context).size.height * 0.015,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: const Color(0xFF4beb44),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showNewDot)
            Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.010,
              ),
              child: Transform.translate(
                offset: Offset(0, -fontSize * 0.25), // raise to superscript
                child: Text(
                  '*',
                  style: TextStyle(
                    fontSize: fontSize * 0.70, // smaller than label
                    color: const Color(0xFFCD750F),
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        color: Color(0xFFCD750F),
                        blurRadius: 3,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        color: Color(0x80CD750F),
                        blurRadius: 6,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        color: Color(0x40CD750F),
                        blurRadius: 12,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
