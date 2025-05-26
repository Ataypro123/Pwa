import 'package:hive/hive.dart';

part 'shift_status.g.dart';

@HiveType(typeId: 8)
class ShiftStatus extends HiveObject {
  @HiveField(0)
  final String shiftId; // Уникальный идентификатор смены

  @HiveField(1)
  bool isOpen; // Открыта ли смена

  @HiveField(2)
  final DateTime openedAt; // Дата открытия смены

  @HiveField(3)
  DateTime? closedAt; // Дата закрытия смены

  @HiveField(4)
  double initialCash; // Начальная сумма наличных в кассе

  @HiveField(5)
  double totalCashAdded; // Общая сумма внесений

  @HiveField(6)
  double totalCashWithdrawn; // Общая сумма изъятий

  ShiftStatus({
    required this.shiftId,
    required this.isOpen,
    required this.openedAt,
    this.closedAt,
    this.initialCash = 0.0,
    this.totalCashAdded = 0.0,
    this.totalCashWithdrawn = 0.0,
  });
  double get currentCashInDrawer {
    return initialCash + totalCashAdded - totalCashWithdrawn;
  }
}
