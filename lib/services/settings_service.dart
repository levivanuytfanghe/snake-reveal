/// Service for managing game settings (game mode, speed).
/// Replaces static state in SettingsScreen with a centralized service.
class SettingsService {
  static final SettingsService _instance = SettingsService._();

  factory SettingsService() => _instance;

  SettingsService._();

  String _selectedMode = 'Classic Mode';
  String _selectedMapName = 'Classic';
  double _selectedSpeed = 3.0;

  String get selectedMode => _selectedMode;
  double get selectedSpeed => _selectedSpeed;
  String get selectedMapName => _selectedMapName;

  void setMode(String mode) {
    _selectedMode = mode;
  }

  void setMapName(String mapName) {
    _selectedMapName = mapName;
  }

  void setSpeed(double speed) {
    _selectedSpeed = speed;
  }

  void reset() {
    _selectedMode = 'Classic Mode';
    _selectedMapName = 'Classic';
    _selectedSpeed = 3.0;
  }
}
