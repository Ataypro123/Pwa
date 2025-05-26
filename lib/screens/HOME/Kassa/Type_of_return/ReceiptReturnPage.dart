import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../Data/payment_method.dart';
import '../../../../Data/receipt_item.dart';
import '../../../../Data/shared_item.dart';


class ReceiptReturnPage extends StatefulWidget {
  const ReceiptReturnPage({Key? key}) : super(key: key);

  @override
  _ReceiptReturnPageState createState() => _ReceiptReturnPageState();
}

class _ReceiptReturnPageState extends State<ReceiptReturnPage> {
  final TextEditingController receiptController = TextEditingController();
  final receiptBox = Hive.box<ReceiptItem>('receiptBox');
  final sharedItemsBox = Hive.box<SharedItem>('sharedItemsBox');
  ReceiptItem? foundReceipt; // Найденный чек
  PaymentMethod selectedPaymentMethod = PaymentMethod.cash; // Метод оплаты возврата по умолчанию
  String errorMessage = ''; // Сообщение об ошибке

  /// Поиск чека по номеру
  void _searchReceipt() {
    final receiptNumber = receiptController.text.trim();

    // Проверяем существование чека
    try {
      final receipt = receiptBox.values.firstWhere(
        (element) => element.receiptNumber == receiptNumber,
      );

      setState(() {
        if (receipt.hasReturn) {
          errorMessage = 'Возврат по этому чеку уже выполнен.';
          foundReceipt = null;
        } else {
          foundReceipt = receipt;
          errorMessage = '';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Чек с таким номером не найден.';
        foundReceipt = null;
      });
    }
  }

  /// Диалог выбора метода оплаты
  Future<void> _selectPaymentMethod() async {
    final selected = await showDialog<PaymentMethod>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выберите метод оплаты возврата'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: PaymentMethod.values.map((method) {
              return ListTile(
                title: Text(method.name),
                onTap: () {
                  Navigator.of(context).pop(method);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedPaymentMethod = selected;
      });
    }
  }

  /// Подтверждение возврата с учетом причины и метода оплаты
  Future<void> _confirmReturn() async {
    if (foundReceipt == null) return;

    // Показываем выбор причины возврата
    final reason = await _showReturnReasonDialog();
    if (reason == null) return; // Если пользователь закрыл диалог без выбора

    final shouldReturnToShelf = (reason == 'Не понравился товар');

    for (var item in foundReceipt!.items) {
      if (shouldReturnToShelf) {
        final existingItemIndex = sharedItemsBox.values
            .toList()
            .indexWhere((shared) => shared.barcode == item.barcode);

        if (existingItemIndex != -1) {
          final existingItem = sharedItemsBox.getAt(existingItemIndex)!;
          existingItem.quantity += item.quantity;
          await existingItem.save();
        } else {
          await sharedItemsBox.add(SharedItem(
            barcode: item.barcode,
            name: item.name,
            quantity: item.quantity,
            price: item.price,
            price2: item.price2,
          ));
        }
      }
    }

    // Обновляем статус чека
    foundReceipt!.hasReturn = true;
    await foundReceipt!.save();

    // Записываем возврат в returnBox
    final returnBox = Hive.box<ReturnItem>('returnBox');
    await returnBox.add(ReturnItem(
      returnType: 'по чеку',
      items: List.from(foundReceipt!.items),
      returnDate: DateTime.now(),
      createdAt: DateTime.now(),
      paymentMethod: selectedPaymentMethod,
      comment:
          'Возврат по чеку №${foundReceipt!.receiptNumber} (${reason})',
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Возврат выполнен: $reason, метод оплаты: ${selectedPaymentMethod.name}.')),
    );

    setState(() {
      foundReceipt = null; // Сбрасываем найденный чек
      receiptController.clear();
    });
  }

  /// Диалог выбора причины возврата
  Future<String?> _showReturnReasonDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Причина возврата'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Не понравился товар'),
                onTap: () {
                  Navigator.of(context).pop('Не понравился товар');
                },
              ),
              ListTile(
                title: const Text('Возврат по браку'),
                onTap: () {
                  Navigator.of(context).pop('Возврат по браку');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Возврат по чеку'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Введите номер чека:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: receiptController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Номер чека',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _searchReceipt,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800]),
              child: const Text('Найти чек'),
            ),
            const SizedBox(height: 20.0),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            if (foundReceipt != null) ...[
              const Text(
                'Данные чека:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Text(
                'Чек №${foundReceipt!.receiptNumber}',
                style: const TextStyle(fontSize: 14.0),
              ),
              const SizedBox(height: 10.0),
              Text(
                'Сумма: ${foundReceipt!.totalAmount.toStringAsFixed(2)} сом',
                style: const TextStyle(fontSize: 14.0),
              ),
              const SizedBox(height: 10.0),
              const Text('Товары:', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: foundReceipt!.items.length,
                  itemBuilder: (context, index) {
                    final item = foundReceipt!.items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('Количество: ${item.quantity} x ${item.price2.toStringAsFixed(2)} сом'),
                      trailing: Text('${(item.quantity * item.price2).toStringAsFixed(2)} сом'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _selectPaymentMethod,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text('Метод оплаты: ${selectedPaymentMethod.name}'),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: ElevatedButton(
                  onPressed: _confirmReturn,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700]),
                  child: const Text('Подтвердить возврат'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
