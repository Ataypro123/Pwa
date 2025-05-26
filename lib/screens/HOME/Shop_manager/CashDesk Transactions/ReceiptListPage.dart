import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../Data/receipt_item.dart';
import '../../../../Data/shared_item.dart';
import 'ReceiptDetailPage.dart'; // Импорт страницы с детальной информацией

class ReceiptListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final receiptBox = Hive.box<ReceiptItem>('receiptBox');
    final sharedItemsBox = Hive.box<SharedItem>('sharedItemsBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Список чеков'),
        backgroundColor: Color.fromRGBO(176, 106, 179, 1),
      ),
      body: ValueListenableBuilder(
        valueListenable: receiptBox.listenable(),
        builder: (context, Box<ReceiptItem> box, _) {
          final receipts = box.values.toList();

          if (receipts.isEmpty) {
            return const Center(
              child: Text(
                'Чеков пока нет.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              final isDeleted = receipt.isDeleted;

              return GestureDetector(
                onTap: () {
                  if (!isDeleted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptDetailPage(receipt: receipt),
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: isDeleted ? Colors.red : Colors.blueAccent,
                          child: Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Чек №${receipt.receiptNumber}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDeleted ? Colors.red : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Сумма: ${receipt.totalAmount.toStringAsFixed(2)} сом',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Метод оплаты: ${receipt.paymentMethod}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Комментарий: ${receipt.comment ?? "Нет"}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                              receipt.hasReturn ? 'Возврат произведён' : 'Нет возврата',
                              style: TextStyle(
                                color: receipt.hasReturn ? Colors.green : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isDeleted ? Icons.restore : Icons.delete,
                            color: isDeleted ? Colors.green : Colors.red,
                          ),
                          onPressed: () async {
                            if (isDeleted) {
                              await _restoreReceipt(receipt, sharedItemsBox);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Чек восстановлен и товары возвращены в чек.')),
                              );
                            } else {
                              await _markAsDeleted(receipt, sharedItemsBox);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Чек помечен на удаление и товары возвращены в витрину.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

Future<void> _markAsDeleted(ReceiptItem receipt, Box<SharedItem> sharedItemsBox) async {
  
  for (var cartItem in receipt.items) {
    // Поиск товара в витрине
    final hiveItemIndex = sharedItemsBox.values.toList().indexWhere((item) => item.barcode == cartItem.barcode);

    if (hiveItemIndex != -1) {
      // Если товар найден, увеличиваем количество
      final hiveItem = sharedItemsBox.getAt(hiveItemIndex)!;
      hiveItem.quantity += cartItem.quantity;
      await hiveItem.save();
    } else {
      // Если товара нет в витрине, создаём новый
      final newItem = SharedItem(
        barcode: cartItem.barcode,
        name: cartItem.name,
        quantity: cartItem.quantity,
        price: cartItem.price,
        price2: cartItem.price2,
      );
      await sharedItemsBox.add(newItem);
    }
  }

  // Помечаем чек как удалённый
  receipt.isDeleted = true;
  await receipt.save();
}


  Future<void> _restoreReceipt(ReceiptItem receipt, Box<SharedItem> sharedItemsBox) async {
  for (var cartItem in receipt.items) {
    // Поиск товара в витрине
    final hiveItemIndex = sharedItemsBox.values.toList().indexWhere((item) => item.barcode == cartItem.barcode);

    if (hiveItemIndex != -1) {
      final hiveItem = sharedItemsBox.getAt(hiveItemIndex)!;

      // Проверяем, достаточно ли товара для вычитания
      if (hiveItem.quantity >= cartItem.quantity) {
        hiveItem.quantity -= cartItem.quantity;
        if (hiveItem.quantity == 0) {
          // Удаляем товар, если его количество стало 0
          await hiveItem.delete();
        } else {
          await hiveItem.save();
        }
      }
    }
  }

  // Убираем флаг удаления
  receipt.isDeleted = false;
  await receipt.save();
}
}
