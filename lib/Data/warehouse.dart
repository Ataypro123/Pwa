import 'package:hive_flutter/hive_flutter.dart';

part 'warehouse.g.dart';

@HiveType(typeId: 3)
class Warehouse extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  int color; // Цвет хранится как ARGB (int)

  Warehouse({
    required this.id,
    required this.name,
    this.color = 0xFFFFFFFF, // По умолчанию белый цвет
  });

  String get deliveryBoxName => 'deliveryBox_$id'; // Уникальная коробка для склада
}
