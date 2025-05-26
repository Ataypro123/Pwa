import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../Data/cash_book_line.dart';
import '../../../Data/shared_item.dart';
import '../../../Data/shift_status.dart';
import 'PaymentPage.dart';
import 'ReturnGoodsPage.dart';
import 'CashdeskOperations.dart';


class CashierScreen extends StatefulWidget {
  @override
  _CashierScreenState createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  late List<SharedItem> cartItems; // Список товаров в чеке
  late Box<SharedItem> sharedItemsBox; // Витрина товаров
  late Box<ShiftStatus> shiftStatusBox; // Хранение статуса смены
  bool isShiftOpen = false; // Статус смены
  ShiftStatus? currentShift; // Текущая смена
  CashBookLine? currentShiftLine;

  @override
  void initState() {
    super.initState();
    sharedItemsBox = Hive.box<SharedItem>('sharedItemsBox'); // Инициализация витрины
    shiftStatusBox = Hive.box<ShiftStatus>('shiftStatusBox');
    cartItems = [];
    _loadLastShift();

  }
// Загрузка статуса смены из Hive
  void _loadLastShift() {
  final lastShift = shiftStatusBox.get('currentShift');
  if (lastShift != null && lastShift.isOpen) {
    setState(() {
      currentShift = lastShift;
      isShiftOpen = lastShift.isOpen;
    });
  }
}

  // Очистка чека
  void _clearCart() {
    if (!_checkShiftStatus()) return;
    setState(() {
      cartItems.clear();
    });
  }
// Проверка статуса смены
  bool _checkShiftStatus() {
    if (!isShiftOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Откройте смену, чтобы выполнить операцию.')),
      );
      return false;
    }
    return true;
  }
void _showCashOperationsDialog() {
    setState(() {
      Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CashdeskOperations()),
);
    });
  }
  void _return() {
    if (!_checkShiftStatus()) return;
    setState(() {
      Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ReturnGoodsPage()),
);
    });
  }
  // Расчет итога чека
  double _calculateTotal() {
    return cartItems.fold(
        0.0, (sum, item) => sum + (item.price2 * item.quantity));
  }
  
  // Расчёт итогов смены
  void _calculateShiftSummary() {
    // Пример: здесь можно подгрузить данные о продажах и возвратах
    // Сохранять их в базе данных или отправлять на сервер
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Начат расчёт статистики за смену.')),
    );
  }
  // Открытие диалога добавления товара
  Future<void> _showAddItemDialog() async {
    if (!_checkShiftStatus()) return;
    showDialog(
      context: context,
      builder: (context) {
        final vitrinaItems = sharedItemsBox.values.toList();
        return AlertDialog(
          title: const Text('Выберите товар'),
          content: vitrinaItems.isEmpty
              ? const Text('В витрине нет товаров.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: vitrinaItems.length,
                    itemBuilder: (context, index) {
                      final item = vitrinaItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                            'Цена: ${item.price2} сом | Количество: ${item.quantity}'),
                        onTap: () {
                          setState(() {
                            final existingIndex = cartItems.indexWhere(
                                (cartItem) => cartItem.barcode == item.barcode);

                            if (existingIndex != -1) {
                              cartItems[existingIndex].quantity++;
                            } else {
                              cartItems.add(SharedItem(
                                barcode: item.barcode,
                                name: item.name,
                                quantity: 1,
                                price: item.price,
                                price2: item.price2,
                              ));
                            }
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  // Открытие диалога установки скидки
  Future<void> _showManualDiscountDialog(int index) async {
    final item = cartItems[index];
    final discountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ручная скидка: ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Текущая цена: ${item.price2.toStringAsFixed(2)} сом'),
              const SizedBox(height: 16),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Новая цена',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(discountController.text.trim());
                if (newPrice != null && newPrice > 0) {
                  setState(() {
                    cartItems[index] = SharedItem(
                      barcode: item.barcode,
                      name: item.name,
                      quantity: item.quantity,
                      price: item.price, // Применяем новую цену
                      price2: newPrice,
                    );
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Цена товара обновлена: ${newPrice.toStringAsFixed(2)} сом')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите корректную цену')),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color.fromARGB(255, 106, 179, 112),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: const Text(
                'Касса',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 106, 179, 112),
                      Color.fromRGBO(176, 106, 179, 1)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          Icons.add_box, 'Добавить товар',() {
                            if (_checkShiftStatus()) _showAddItemDialog();
                          },),
                        _buildActionButton(
                          Icons.undo, 'Возврат', _return),
                        _buildActionButton(
                          Icons.delete, 'Очистить чек', _clearCart),
                        _buildActionButton(
                          Icons.account_balance_wallet,'Кассовые операции', _showCashOperationsDialog),
                      ],
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Список товаров в чеке
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: Text(item.name),
                        subtitle: Text(
                            'Количество: ${item.quantity} | Цена: ${item.price2} сом'),
                        trailing: Text(
                            '${(item.quantity * item.price2).toStringAsFixed(2)} сом'),
                        onTap: () {
                          _showManualDiscountDialog(index);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Итоги чека
                  _buildCartSummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCartSummary() {
    final total = _calculateTotal();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Итого:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${total.toStringAsFixed(2)} сом',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (cartItems.isNotEmpty) // Показываем кнопку только если есть товары в корзине
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(
                    cartItems: cartItems,
                    totalAmount: _calculateTotal(),
                    onReceiptPrinted: _clearCart, // Callback to clear cart
                    sharedItemsBox: sharedItemsBox, // Передача Box в PaymentPage
                  ),
                ),
              );
            },
            child: const Text(
              'Перейти к оплате',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}