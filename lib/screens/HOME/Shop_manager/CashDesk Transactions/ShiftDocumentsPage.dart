import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../Data/shift_status.dart';

class ShiftDocumentsPage extends StatelessWidget {
  const ShiftDocumentsPage({Key? key}) : super(key: key);

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Неизвестно';
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  void addShiftDocument({
    required bool isOpen,
    required double initialCash,
    double totalCashAdded = 0.0,
    double totalCashWithdrawn = 0.0,
    DateTime? openedAt,
    DateTime? closedAt,
    String? shiftId,
  }) {
    final shiftStatusBox = Hive.box<ShiftStatus>('shiftStatusBox');

    if (shiftId != null) {
      // Если передан shiftId, обновляем существующую смену
      final shift = shiftStatusBox.values.cast<ShiftStatus>().firstWhere(
            (s) => s.shiftId == shiftId,
            orElse: () => throw Exception('Shift not found'),
          );
      shift
        ..isOpen = isOpen
        ..closedAt = closedAt
        ..save();
    } else {
      // Добавляем новую смену
      final newShift = ShiftStatus(
        shiftId: DateTime.now().millisecondsSinceEpoch.toString(),
        isOpen: isOpen,
        openedAt: isOpen ? (openedAt ?? DateTime.now()) : DateTime.now(),
        closedAt: isOpen ? null : (closedAt ?? DateTime.now()),
        initialCash: initialCash,
        totalCashAdded: totalCashAdded,
        totalCashWithdrawn: totalCashWithdrawn,
      );
      shiftStatusBox.add(newShift);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftStatusBox = Hive.box<ShiftStatus>('shiftStatusBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Документы смен'),
        backgroundColor: const Color.fromRGBO(176, 106, 179, 1),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final lastShift = shiftStatusBox.values.cast<ShiftStatus>().lastWhere(
                (shift) => shift.isOpen,
                orElse: () => ShiftStatus(
                  shiftId: '',
                  isOpen: false,
                  openedAt: DateTime.now(),
                  initialCash: 0.0,
                ),
              );

          if (lastShift.isOpen) {
            // Закрываем текущую смену
            addShiftDocument(
              isOpen: false,
              initialCash: lastShift.initialCash,
              totalCashAdded: lastShift.totalCashAdded,
              totalCashWithdrawn: lastShift.totalCashWithdrawn,
              closedAt: DateTime.now(),
              shiftId: lastShift.shiftId,
            );
          } else {
            // Открываем новую смену
            addShiftDocument(
              isOpen: true,
              initialCash: 100.0, // Пример начальной суммы
              openedAt: DateTime.now(),
            );
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
      body: ValueListenableBuilder(
        valueListenable: shiftStatusBox.listenable(),
        builder: (context, Box<ShiftStatus> box, _) {
          final shifts = box.values.cast<ShiftStatus>().toList();

          if (shifts.isEmpty) {
            return const Center(
              child: Text('Нет сохранённых документов.'),
            );
          }

          return ListView.separated(
            itemCount: shifts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final shift = shifts[index];
              return ListTile(
                leading: Icon(
                  shift.isOpen ? Icons.lock_open : Icons.lock,
                  color: shift.isOpen ? Colors.green : Colors.red,
                ),
                title: Text(shift.isOpen ? 'Смена открыта' : 'Смена закрыта'),
                subtitle: Text(
                  shift.isOpen
                      ? 'Дата открытия: ${formatDateTime(shift.openedAt)}'
                      : 'Дата закрытия: ${formatDateTime(shift.closedAt)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    // Дополнительно: можно показать больше информации о смене
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
