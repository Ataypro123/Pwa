import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../Data/receipt_item.dart';
import 'DebtorReceiptDetailPage.dart';

class DebtorReceiptsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final debtorReceiptBox = Hive.box<DebtorItem>('debtorReceiptBox'); // Box для должников

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чеки должников'),
        backgroundColor: Colors.redAccent,
      ),
      body: ValueListenableBuilder(
        valueListenable: debtorReceiptBox.listenable(),
        builder: (context, Box<DebtorItem> box, _) {
          final receipts = box.values.toList();

          if (receipts.isEmpty) {
            return const Center(
              child: Text(
                'Чеков должников пока нет.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text('Чек №${receipt.receiptNumber}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Сумма: ${receipt.totalAmount.toStringAsFixed(2)} сом\n'
                    'Дата возврата: ${receipt.returnDate.toLocal()}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DebtorReceiptDetailPage(receipt: receipt,),
                      ),
                    );
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
