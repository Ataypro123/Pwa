import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../Data/payment_method.dart';
import '../../../Data/receipt_item.dart';
import '../../../Data/shared_item.dart';

Future<String> _generateReceiptNumber(Box<ReceiptItem> box) async {
  final count = box.length + 1;
  return count.toString().padLeft(10, '0');
}

class PaymentPage extends StatefulWidget {
  final List<SharedItem> cartItems;
  final double totalAmount;
  final VoidCallback onReceiptPrinted;
  final Box<SharedItem> sharedItemsBox;

  const PaymentPage({
    required this.cartItems,
    required this.totalAmount,
    required this.onReceiptPrinted,
    required this.sharedItemsBox,
    Key? key,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod selectedPaymentMethod = PaymentMethod.cash; // По умолчанию - Наличные
  final TextEditingController commentController = TextEditingController();
  final TextEditingController debtAmountController = TextEditingController();
  final TextEditingController debtNameController = TextEditingController();
  final TextEditingController debtPhoneController = TextEditingController();
  final Box<DebtorItem> debtorReceiptBox = Hive.box<DebtorItem>('debtorReceiptBox');

  DateTime? selectedReturnDate;

  Future<void> _pickReturnDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedReturnDate = picked;
      });
    }
  }

  Future<void> _printReceipt() async {
    final comment = commentController.text.trim();
    final receiptBox = Hive.box<ReceiptItem>('receiptBox');
    final receiptNumber = await _generateReceiptNumber(receiptBox);

    if (selectedPaymentMethod == PaymentMethod.card || selectedPaymentMethod == PaymentMethod.qr) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Подтверждение оплаты'),
            content: const Text('Вы получили подтверждение оплаты?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Нет'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Да'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Оплата не подтверждена. Чек не сохранён.')),
        );
        return;
      }
    }

    final receipt = ReceiptItem(
      receiptNumber: receiptNumber,
      items: List.from(widget.cartItems),
      totalAmount: widget.totalAmount,
      paymentMethod: selectedPaymentMethod,
      createdAt: DateTime.now(),
      comment: comment,
    );

    if (selectedPaymentMethod == PaymentMethod.debt) {
      final debtAmount = debtAmountController.text.trim();

      if (selectedReturnDate == null || debtAmount.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, укажите дату возврата и сумму долга.')),
        );
        return;
      }

      final debtorItem = DebtorItem(
        receiptNumber: receipt.receiptNumber,
        items: receipt.items,
        totalAmount: double.parse(debtAmount),
        debtorName: debtNameController.text.trim(),
        debtorPhone: debtPhoneController.text.trim(),
        paymentMethod: 'В долг',
        createdAt: receipt.createdAt,
        returnDate: selectedReturnDate!,
        comment: receipt.comment,
      );

      await debtorReceiptBox.add(debtorItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Чек добавлен в список должников. Дата возврата: ${DateFormat('yyyy-MM-dd').format(selectedReturnDate!)}',
          ),
        ),
      );
    } else {
      await receiptBox.add(receipt);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Чек сохранён. Способ оплаты: ${selectedPaymentMethod.name}')),
      );

      for (var cartItem in widget.cartItems) {
        final hiveItemIndex = widget.sharedItemsBox.values
            .toList()
            .indexWhere((item) => item.barcode == cartItem.barcode);

        if (hiveItemIndex != -1) {
          final hiveItem = widget.sharedItemsBox.getAt(hiveItemIndex)!;

          if (hiveItem.quantity > cartItem.quantity) {
            hiveItem.quantity -= cartItem.quantity;
            hiveItem.save();
          } else {
            hiveItem.delete();
          }
        }
      }

      widget.onReceiptPrinted();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оплата'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Список товаров:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    return ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: Text(item.name),
                      subtitle: Text(
                        'Количество: ${item.quantity} | Цена: ${item.price2.toStringAsFixed(2)} сом',
                      ),
                      trailing: Text(
                        '${(item.quantity * item.price2).toStringAsFixed(2)} сом',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Выберите способ оплаты:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: PaymentMethod.values.map((method) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedPaymentMethod = method;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPaymentMethod == method
                          ? Colors.green
                          : Colors.grey[300],
                      foregroundColor: selectedPaymentMethod == method
                          ? Colors.white
                          : Colors.black,
                    ),
                    child: Text(method.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (selectedPaymentMethod == PaymentMethod.debt) ...[
                const Text(
                  'Дата возврата:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickReturnDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedReturnDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedReturnDate!)
                          : 'Выберите дату',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Сумма долга:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: debtAmountController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите сумму долга',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Имя и фамилия (необязательно):',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: debtNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите имя и фамилию',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Номер телефона (необязательно):',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: debtPhoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите номер телефона',
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _printReceipt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.print, color: Colors.white),
                  label: const Text(
                    'Распечатать чек',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
