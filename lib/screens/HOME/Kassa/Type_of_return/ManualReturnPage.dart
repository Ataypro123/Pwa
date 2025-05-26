import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../Data/payment_method.dart';
import '../../../../Data/receipt_item.dart';
import '../../../../Data/shared_item.dart';


class ManualReturnPage extends StatefulWidget {
  const ManualReturnPage({Key? key}) : super(key: key);

  @override
  _ManualReturnPageState createState() => _ManualReturnPageState();
}

class _ManualReturnPageState extends State<ManualReturnPage> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController price2Controller = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final List<SharedItem> itemsToReturn = [];
  late Box<SharedItem> sharedItemsBox;
  PaymentMethod selectedPaymentMethod = PaymentMethod.cash; // Метод оплаты по умолчанию

  @override
  void initState() {
    super.initState();
    sharedItemsBox = Hive.box<SharedItem>('sharedItemsBox');
  }

  void _addItemToList() {
    final barcode = barcodeController.text.trim();
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final price2 = double.tryParse(price2Controller.text.trim());
    final quantity = int.tryParse(quantityController.text.trim());

    if (barcode.isEmpty ||
        name.isEmpty ||
        price == null ||
        price2 == null ||
        quantity == null ||
        quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля корректно.')),
      );
      return;
    }

    final newItem = SharedItem(
      barcode: barcode,
      name: name,
      quantity: quantity,
      price: price,
      price2: price2,
    );

    setState(() {
      itemsToReturn.add(newItem);
    });

    // Очистка полей после добавления
    barcodeController.clear();
    nameController.clear();
    priceController.clear();
    price2Controller.clear();
    quantityController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар добавлен в список.')),
    );
  }

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
                title: Text(method.name), // Отображаем имя через PaymentMethodExtension
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

  void _saveAllItemsToStore() async {
    final reason = await _showReturnReasonDialog();
    if (reason == null) return; // Если пользователь закрыл диалог без выбора

    final shouldReturnToShelf = (reason == 'Не понравился товар');

    for (var item in itemsToReturn) {
      if (shouldReturnToShelf) {
        final existingItemIndex = sharedItemsBox.values
            .toList()
            .indexWhere((shared) => shared.barcode == item.barcode);

        if (existingItemIndex != -1) {
          final existingItem = sharedItemsBox.getAt(existingItemIndex)!;
          existingItem.quantity += item.quantity;
          await existingItem.save();
        } else {
          await sharedItemsBox.add(item);
        }
      }
    }

    // Сохраняем возврат в returnBox
    final returnBox = Hive.box<ReturnItem>('returnBox');
    await returnBox.add(
      ReturnItem(
        returnType: 'ручной',
        items: List.from(itemsToReturn), // Копия списка товаров
        returnDate: DateTime.now(),
        createdAt: DateTime.now(),
        paymentMethod: selectedPaymentMethod, // Сохраняем выбранный метод оплаты
        comment: 'Ручной возврат (${reason})',
      ),
    );

    setState(() {
      itemsToReturn.clear(); // Очищаем список
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Возврат выполнен: $reason, метод оплаты: ${selectedPaymentMethod.name}.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ручной возврат'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField('Штрихкод товара', barcodeController),
            const SizedBox(height: 10.0),
            _buildTextField('Название товара', nameController),
            const SizedBox(height: 10.0),
            _buildTextField('Цена 1 (себестоимость)', priceController,
                inputType: TextInputType.number),
            const SizedBox(height: 10.0),
            _buildTextField('Цена 2 (продажа)', price2Controller,
                inputType: TextInputType.number),
            const SizedBox(height: 10.0),
            _buildTextField('Количество', quantityController,
                inputType: TextInputType.number),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _addItemToList,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800]),
                  child: const Text('Добавить в список'),
                ),
                ElevatedButton(
                  onPressed: _saveAllItemsToStore,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700]),
                  child: const Text('Сохранить всё'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _selectPaymentMethod,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(
                  'Метод оплаты: ${selectedPaymentMethod.name}'),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: itemsToReturn.length,
                itemBuilder: (context, index) {
                  final item = itemsToReturn[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text('${item.name} (x${item.quantity})'),
                      subtitle: Text(
                        'Штрихкод: ${item.barcode}\nЦена 1: ${item.price} сом, Цена 2: ${item.price2} сом',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            itemsToReturn.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {TextInputType? inputType}) {
    return TextField(
      controller: controller,
      keyboardType: inputType ?? TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }
}
