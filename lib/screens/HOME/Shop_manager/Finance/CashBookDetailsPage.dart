import 'package:flutter/material.dart';
import '../../../../Data/cash_book_line.dart';

class CashBookDetailsPage extends StatelessWidget {
  final CashBookLine cashBookLine;
  final double cashBeforeOpening; // Наличные до открытия смены

  const CashBookDetailsPage({
    Key? key,
    required this.cashBookLine,
    required this.cashBeforeOpening,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cashAdded = cashBookLine.totalCashAdded;
    final double cashWithdrawn = cashBookLine.totalCashWithdrawn;
    final double cashAfterClosing =
        cashBeforeOpening - cashAdded + cashWithdrawn;

    return Scaffold(
      appBar: AppBar(
        title: Text('Детали смены: ${cashBookLine.lineId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Смена открыта: ${cashBookLine.openedAt}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Смена закрыта: ${cashBookLine.closedAt ?? 'Не закрыта'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Остаток до открытия смены: ${cashBeforeOpening.toStringAsFixed(2)} сом',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'РКО (внесения): ${cashWithdrawn.toStringAsFixed(2)} сом',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'ПКО (изъятие): ${cashAdded.toStringAsFixed(2)} сом',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Остаток после закрытия смены: ${cashAfterClosing.toStringAsFixed(2)} сом',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Документы смены:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: cashBookLine.documents.length,
                itemBuilder: (context, index) {
                  final document = cashBookLine.documents[index];
                  return ListTile(
                    title: Text(
                      '${document.type == CashDocumentType.deposit ? 'Расходный кассовый ордер (РКО)' : 'Приходный кассовый ордер (РКО)'}: ${document.amount.toStringAsFixed(2)} сом',
                    ),
                    subtitle: Text('Дата: ${document.createdAt}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
