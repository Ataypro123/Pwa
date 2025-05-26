
import 'package:hive_flutter/hive_flutter.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 2)
class UserSettings extends HiveObject {
 @HiveField(0)
  bool isSimplified; // Режим: упрощённый или стандартный

  UserSettings({this.isSimplified = false}); // По умолчанию стандартный режим
}

