import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../Data/payment_method.dart';
import '../../../../Data/receipt_item.dart';

class DebtorReceiptDetailPage extends StatelessWidget {
  final DebtorItem receipt;
  const DebtorReceiptDetailPage({required this.receipt, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали чека должника'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Чек №${receipt.receiptNumber}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Сумма: ${receipt.totalAmount.toStringAsFixed(2)} сом',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Дата возврата: ${receipt.returnDate.toLocal()}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Имя клиента: ${receipt.debtorName}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Телефон клиента: ${receipt.debtorPhone}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Список товаров:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: receipt.items.length,
                itemBuilder: (context, index) {
                  final item = receipt.items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                          'Количество: ${item.quantity} | Цена: ${item.price.toStringAsFixed(2)} сом'),
                      trailing: Text(
                        '${(item.quantity * item.price).toStringAsFixed(2)} сом',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _showPaymentOptions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Принять оплату',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выберите способ оплаты:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _processPayment(context, PaymentMethod.cash),
                child: const Text('Наличные'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _processPayment(context, PaymentMethod.card),
                child: const Text('Безналичные'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _processPayment(context, PaymentMethod.qr),
                child: const Text('По QR-коду'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPayment(BuildContext context, PaymentMethod paymentMethod) async {
  final receiptBox = Hive.box<ReceiptItem>('receiptBox');

  // Преобразование DebtorItem в ReceiptItem
  final receiptAsPayment = ReceiptItem(
    receiptNumber: receipt.receiptNumber,
    items: receipt.items,
    totalAmount: receipt.totalAmount,
    paymentMethod: paymentMethod, // Новый метод оплаты
    createdAt: receipt.createdAt, // Дата создания сохраняется
    comment: receipt.comment, // Переносим комментарий
  );

  await receiptBox.add(receiptAsPayment); // Добавляем в ReceiptBox
  await receipt.delete(); // Удаляем из DebtorReceiptBox

  Navigator.pop(context); // Закрыть BottomSheet
  Navigator.pop(context); // Закрыть детали

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Чек перемещён в оплаченные: $paymentMethod')),
  );
}

}
