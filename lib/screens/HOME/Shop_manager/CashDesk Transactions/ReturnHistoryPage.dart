import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../Data/receipt_item.dart';
import '../../../../Data/shared_item.dart';
import 'ReceiptDetailsPage.dart';

class ReturnHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final returnBox = Hive.box<ReturnItem>('returnBox');
    final sharedItemsBox = Hive.box<SharedItem>('sharedItemsBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Список возвратов'),
        backgroundColor: const Color.fromRGBO(176, 106, 179, 1),
      ),
      body: ValueListenableBuilder(
        valueListenable: returnBox.listenable(),
        builder: (context, Box<ReturnItem> box, _) {
          final returns = box.values.toList();

          if (returns.isEmpty) {
            return const Center(
              child: Text(
                'Возвратов пока нет.',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          }

          return ListView.builder(
            itemCount: returns.length,
            itemBuilder: (context, index) {
              final receipt = returns[index];
              final isDeleted = receipt.isDeleted;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptDetailsPage(receipt: receipt),
                    ),
                  );
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
                          onPressed: () {
                            _showPasswordDialog(
                              context: context,
                              isDeleted: isDeleted,
                              onSuccess: () async {
                                if (isDeleted) {
                                  await _restoreReceipt(receipt, sharedItemsBox);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Чек восстановлен и товары возвращены в чек.')),
                              );
                            } else {
                              await _markAsDeleted(receipt, sharedItemsBox);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Чек помечен на удаление и товары возвращены в витрину.')),
                              );
                            }
                          },
                        );
                        },
                        )
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
void _showPasswordDialog({
    required BuildContext context,
    required bool isDeleted,
    required VoidCallback onSuccess,
  }) {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isDeleted ? 'Восстановить чек' : 'Удалить чек'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Введите пароль для подтверждения:'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог без действия
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == '123456') {
                  Navigator.of(context).pop(); // Закрыть диалог
                  onSuccess(); // Выполнить действие
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Неверный пароль!')),
                  );
                }
              },
              child: const Text('Подтвердить'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _markAsDeleted(ReturnItem receipt, Box<SharedItem> sharedItemsBox) async {
    for (var cartItem in receipt.items) {
      final hiveItemIndex =
          sharedItemsBox.values.toList().indexWhere((item) => item.barcode == cartItem.barcode);
      if (hiveItemIndex != -1) {
        final hiveItem = sharedItemsBox.getAt(hiveItemIndex)!;
        hiveItem.quantity -= cartItem.quantity;
        await hiveItem.save();
      } else {
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
    receipt.isDeleted = true;
    await receipt.save();
  }

  Future<void> _restoreReceipt(ReturnItem receipt, Box<SharedItem> sharedItemsBox) async {
    for (var cartItem in receipt.items) {
      final hiveItemIndex =
          sharedItemsBox.values.toList().indexWhere((item) => item.barcode == cartItem.barcode);
      if (hiveItemIndex != -1) {
        final hiveItem = sharedItemsBox.getAt(hiveItemIndex)!;
        if (hiveItem.quantity >= cartItem.quantity) {
          hiveItem.quantity -= cartItem.quantity;
          if (hiveItem.quantity == 0) {
            await hiveItem.delete();
          } else {
            await hiveItem.save();
          }
        }
      }
    }
    receipt.isDeleted = false;
    await receipt.save();
  }

}
