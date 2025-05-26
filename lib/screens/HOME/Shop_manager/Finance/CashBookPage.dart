import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../Data/cash_book_line.dart';
import 'CashBookDetailsPage.dart';

class CashBookPage extends StatefulWidget {
  @override
  _CashBookPageState createState() => _CashBookPageState();
}

class _CashBookPageState extends State<CashBookPage> {
  late Box<CashBookLine> cashBookBox;

  @override
  void initState() {
    super.initState();
    cashBookBox = Hive.box<CashBookLine>('cashBook');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кассовая книга'),
      ),
      body: ValueListenableBuilder(
        valueListenable: cashBookBox.listenable(),
        builder: (context, Box<CashBookLine> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Кассовая книга пуста.'));
          }

          double previousBalance = 0.0; // Начальный остаток (первая строка)

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final cashBookLine = box.getAt(index)!;
              final cashAdded = cashBookLine.totalCashAdded;
              final cashWithdrawn = cashBookLine.totalCashWithdrawn;
              final currentBalance =
                  previousBalance - cashAdded + cashWithdrawn;

              final listTile = ListTile(
                title: Text(
                  'Смена: ${cashBookLine.openedAt} ',
                ),
                subtitle: Text(
                  'Остаток: ${previousBalance.toStringAsFixed(2)} | '
                  'РКО: ${cashWithdrawn.toStringAsFixed(2)} | '
                  'ПКО: ${cashAdded.toStringAsFixed(2)} | '
                  'Итог: ${currentBalance.toStringAsFixed(2)}',
                ),
                onTap: () => _navigateToCashBookLineDetails(
                  cashBookLine,
                  previousBalance,
                ),
              );

              previousBalance = currentBalance; // Обновляем остаток
              return listTile;
            },
          );
        },
      ),
    );
  }

  void _navigateToCashBookLineDetails(
      CashBookLine cashBookLine, double cashBeforeOpening) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashBookDetailsPage(
          cashBookLine: cashBookLine,
          cashBeforeOpening: cashBeforeOpening,
        ),
      ),
    );
  }
}
