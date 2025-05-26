import 'package:hive_flutter/hive_flutter.dart';

import '../../Data/user_settings.dart';

class SettingsManager {
  static const String _settingsBoxName = 'settingsBox';

  static Future<UserSettings> getSettings() async {
    final box = Hive.box<UserSettings>(_settingsBoxName);

    if (box.isEmpty) {
      final defaultSettings = UserSettings(); // По умолчанию стандартный режим
      await box.put('userSettings', defaultSettings);
      return defaultSettings;
    }

    return box.get('userSettings')!;
  }

  static Future<void> updateSimplifiedMode(bool isSimplified) async {
    final settings = await getSettings();
    settings.isSimplified = isSimplified;
    await settings.save();
  }
}
