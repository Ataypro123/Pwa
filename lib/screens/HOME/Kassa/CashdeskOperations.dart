// lib/screens/cashdesk_operations.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Data/cash_book_line.dart';
import '../../../Data/receipt_item.dart';
import '../../../Data/shared_item.dart';
import '../../../Data/shift_status.dart';
import 'CloseShiftPage.dart';
import 'Kassa.dart';

class CashdeskOperations extends StatefulWidget {
  @override
  _CashdeskOperationsState createState() => _CashdeskOperationsState(); 
}
class _CashdeskOperationsState extends State<CashdeskOperations> {

  late List<SharedItem> cartItems; // Список товаров в чеке
  late Box<SharedItem> sharedItemsBox; // Витрина товаров
  late Box<ShiftStatus> shiftStatusBox; // Хранение статуса смены
  bool isShiftOpen = false; // Статус смены
  ShiftStatus? currentShift; // Текущая смена
  CashBookLine? currentShiftLine;
 
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
        'Операции кассы',
        style: TextStyle(
          color: Colors.white, // Устанавливаем белый цвет текста
        ),
      ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 106, 179, 112),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Кнопка "Открытие смены" (появляется, если смена не открыта)
            if (!isShiftOpen)
              Flexible(
                flex: 2,
                child: ActionButton(
                  label: 'Открытие смены',
                  color: Colors.green,
                  onPressed: _openShift,
                ),
              ),

            if (!isShiftOpen)
              const Divider(thickness: 2, height: 20),

            // Остальные кнопки (появляются, если смена открыта)
            if (isShiftOpen) ...[
              // Ряд с кнопками "внесение" и "изъятия"
              Flexible(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        label: 'внесение',
                        color: Colors.teal,
                        onPressed: _showAddCashDialog,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ActionButton(
                        label: 'изъятия',
                        color: Colors.green[700]!,
                        onPressed: _showWithdrawCashDialog,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Кнопка "x-отчет"
              Flexible(
                flex: 2,
                child: ActionButton(
                  label: 'Х-отчет',
                  color: Colors.blue,
                  onPressed:_showXReportDialog,
                ),
              ),
              const SizedBox(height: 8),

              // Кнопка "Регистрация продаж"
              Flexible(
                flex: 4, // Увеличенный flex для этой кнопки
                child: ActionButton(
                  label: 'Регистрация продаж',
                  color: Colors.blue,
                  onPressed: _registersale,
                ),
              ),
              const SizedBox(height: 8),

              // Кнопка "Закрытие смены"
              Flexible(
                flex: 2,
                child: ActionButton(
                  label: 'Закрытие смены',
                  color: Colors.red,
                  onPressed: _closeShift,
                ),
              ),
              const Divider(thickness: 2, height: 20),
            ],

            // Кнопка "Доп. отчеты" (всегда доступна)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ActionButton(
                  label: 'Доп. отчеты',
                  color: Colors.orange,
                  onPressed: _showAdditionalReports,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

void _showAdditionalReports(){

}

@override
  void initState() {
    super.initState();
    shiftStatusBox = Hive.box<ShiftStatus>('shiftStatusBox');
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
 // Сохранение статуса смены в Hive
void _saveShiftStatus({
  required bool isOpen,
  DateTime? openedAt,
  DateTime? closedAt,
}) 
{
  if (isOpen) {
    final newShift = ShiftStatus(
      shiftId: DateTime.now().millisecondsSinceEpoch.toString(), // Уникальный ID
      isOpen: true,
      openedAt: openedAt ?? DateTime.now(),
      closedAt: null,
    );
    shiftStatusBox.put('currentShift', newShift); // Сохраняем как текущую смену
    currentShift = newShift;
  } else {
    if (currentShift == null) return;

    final closedShift = ShiftStatus(
      shiftId: currentShift!.shiftId,
      isOpen: false,
      openedAt: currentShift!.openedAt,
      closedAt: closedAt ?? DateTime.now(),
    );

    shiftStatusBox.put('currentShift', closedShift); // Обновляем текущую смену
    shiftStatusBox.add(closedShift); // Добавляем копию в архив
    currentShift = closedShift;
  }
}
// Открытие смены
void _openShift() {
  if (isShiftOpen) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Смена уже открыта.')),
    );
    return;
  }
  final cashBookBox = Hive.box<CashBookLine>('cashBook');

  // Определяем остаток из последней смены
  double previousBalance = 0.0;
  if (cashBookBox.isNotEmpty) {
    final lastShift = cashBookBox.getAt(cashBookBox.length - 1);
    previousBalance = lastShift?.cashAfterClosing ?? 0.0;
  }

  final newShiftLine = CashBookLine(
    lineId: DateTime.now().millisecondsSinceEpoch.toString(), // Уникальный ID
    openedAt: DateTime.now(),
    documents: [],
    cashBeforeOpening: previousBalance, // Сохраняем остаток

  );

  setState(() {
    isShiftOpen = true;
    currentShiftLine = newShiftLine; // Сохранение текущего листа кассовой книги

  });
  // Сохранение нового листа в Hive
  Hive.box<CashBookLine>('cashBook').add(newShiftLine);

  _saveShiftStatus(isOpen: true, openedAt: DateTime.now());
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Смена успешно открыта.')),
  );

  // Начало расчёта статистики
  _calculateShiftSummary();
}

void _closeShift() {
  if (!isShiftOpen) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Смена ещё не открыта.')),
    );
    return;
  }

  if (currentShift == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Текущая смена отсутствует.')),
    );
    return;
  }

  final openedAt = currentShift!.openedAt;
  final closedAt = currentShift!.closedAt ?? DateTime.now();
  double totalSales = 0.0;
  double totalReturns = 0.0;
  Map<String, double> paymentMethodsTotal = {'cash': 0.0, 'card': 0.0, 'qr': 0.0};
  Map<String, double> returnsByMethod = {'cash': 0.0, 'card': 0.0, 'qr': 0.0};

  // Получаем продажи
  final sales = _filterDataByShift<ReceiptItem>(
    box: Hive.box<ReceiptItem>('receiptBox'),
    openedAt: openedAt,
    closedAt: closedAt,
  );

  for (var receipt in sales) {
    totalSales += receipt.totalAmount;
    final methodName = receipt.paymentMethod.name;
    paymentMethodsTotal[methodName] = (paymentMethodsTotal[methodName] ?? 0.0) + receipt.totalAmount;
  }

  // Получаем возвраты
  final returns = _filterDataByShift<ReturnItem>(
    box: Hive.box<ReturnItem>('returnBox'),
    openedAt: openedAt,
    closedAt: closedAt,
  );

  for (var returnItem in returns) {
    totalReturns += returnItem.items.fold(
        0.0, (sum, item) => sum + (item.quantity * item.price2));
    final methodName = returnItem.paymentMethod.name;
    returnsByMethod[methodName] = (returnsByMethod[methodName] ?? 0.0) +
        returnItem.items.fold(0.0, (sum, item) => sum + (item.quantity * item.price2));
  }

  // Рассчитываем наличные в кассе
  double cashInDrawer = 
      (currentShift!.initialCash ?? 0.0) +
      (currentShift!.totalCashAdded ?? 0.0) -
      (currentShift!.totalCashWithdrawn ?? 0.0) +
      (paymentMethodsTotal['cash'] ?? 0.0) -
      (returnsByMethod['cash'] ?? 0.0);

  // Переход на страницу закрытия смены
  
  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CloseShiftPage(
      totalSales: totalSales,
      totalReturns: totalReturns,
      salesByMethod: paymentMethodsTotal, // Передача данных по методам продаж
      cashDeposits: currentShift?.totalCashAdded ?? 0.0, // Внесение наличных
      cashWithdrawals: currentShift?.totalCashWithdrawn ?? 0.0, // Изъятие наличных
      returnsByMethod: returnsByMethod,
      cashInDrawer: cashInDrawer,
    ),
  ),
);

}


void _registersale (){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CashierScreen(),
    ),
  );
}
  
  // Расчёт итогов смены
  void _calculateShiftSummary() {
    // Пример: здесь можно подгрузить данные о продажах и возвратах
    // Сохранять их в базе данных или отправлять на сервер
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Начат расчёт статистики за смену.')),
    );
  }
  Widget _buildCashOperationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isCompact = false,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: isCompact
            ? const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0)
            : const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        backgroundColor: isCompact ? Colors.grey[200] : Colors.blueAccent,
        foregroundColor: isCompact ? Colors.blueAccent : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: isCompact ? 2 : 6,
      ),
      icon: Icon(icon, size: isCompact ? 20 : 24),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isCompact ? 14 : 16,
          fontWeight: isCompact ? FontWeight.w400 : FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
  void addCashToDrawer(double amount) {
  if (!isShiftOpen) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Откройте смену для внесения.')),
    );
    return;
  }
  final depositDocument = CashDocument(
    documentId: DateTime.now().millisecondsSinceEpoch.toString(),
    type: CashDocumentType.deposit,
    createdAt: DateTime.now(),
    amount: amount,
  );
  setState(() {
    currentShift!.totalCashAdded += amount;
    currentShift!.save();
    currentShiftLine?.addDocument(depositDocument); // Добавление документа
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Добавлено в кассу: ${amount.toStringAsFixed(2)} сом')),
  );
}

void withdrawCashFromDrawer(double amount) {
  if (!isShiftOpen) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Откройте смену для изъятия.')),
    );
    return;
  }

  if (currentShift!.currentCashInDrawer < amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Недостаточно средств в кассе.')),
    );
    return;
  }
final withdrawalDocument = CashDocument(
    documentId: DateTime.now().millisecondsSinceEpoch.toString(),
    type: CashDocumentType.withdrawal,
    createdAt: DateTime.now(),
    amount: amount,
  );
  setState(() {
    currentShift!.totalCashWithdrawn += amount;
    currentShift!.save();
    currentShiftLine?.addDocument(withdrawalDocument); // Добавление документа
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Изъято из кассы: ${amount.toStringAsFixed(2)} сом')),
  );
}

void _showAddCashDialog() {
  // Калькуляция
  Map<String, double> paymentMethodsTotal = {'cash': 0.0,};
  Map<String, double> returnsByMethod = {'cash': 0.0,};
  // Метод для расчёта наличных в кассе
  double calculateCashInDrawer() {
    if (currentShift == null) return 0.0; // Защита от null
    return currentShift!.initialCash + // Начальная сумма
           currentShift!.totalCashAdded - // Все внесения
           currentShift!.totalCashWithdrawn + // Все изъятия
           paymentMethodsTotal['cash']! - // Оплаты наличными
           returnsByMethod['cash']!; // Возвраты наличными
  }
  final amountController = TextEditingController();
final cashInDrawer = calculateCashInDrawer(
  );
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Внесение средств'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Текущая наличность в кассе: ${cashInDrawer.toStringAsFixed(2)} сом',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Сумма',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount != null && amount > 0) {
                addCashToDrawer(amount);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите корректную сумму.')),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      );
    },
  );
}

void _showWithdrawCashDialog() {
   // Калькуляция
  Map<String, double> paymentMethodsTotal = {'cash': 0.0,};
  Map<String, double> returnsByMethod = {'cash': 0.0,};
  // Метод для расчёта наличных в кассе
  double calculateCashInDrawer() {
    if (currentShift == null) return 0.0; // Защита от null
    return currentShift!.initialCash + // Начальная сумма
           currentShift!.totalCashAdded - // Все внесения
           currentShift!.totalCashWithdrawn + // Все изъятия
           paymentMethodsTotal['cash']! - // Оплаты наличными
           returnsByMethod['cash']!; // Возвраты наличными
  }
  final amountController = TextEditingController();
  final cashInDrawer = calculateCashInDrawer(
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Изъятие средств'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Текущая наличность в кассе: ${cashInDrawer.toStringAsFixed(2)} сом',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Сумма',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount != null && amount > 0) {
                if (currentShift!.currentCashInDrawer >= amount) {
                  withdrawCashFromDrawer(amount);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Недостаточно средств в кассе.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите корректную сумму.')),
                );
              }
            },
            child: const Text('Изъять'),
          ),
        ],
      );
    },
  );
}




  //x-report
List<T> _filterDataByShift<T>({
  required Box<T> box,
  required DateTime openedAt,
  DateTime? closedAt,
  bool Function(T item)? filter,
}) {
  final List<T> filteredData = [];

  for (var item in box.values) {
    final DateTime itemDate = (item as dynamic).createdAt ?? (item as dynamic).returnDate; // Пример: чекам добавлен `createdAt`
    if (itemDate.isAfter(openedAt) && (closedAt == null || itemDate.isBefore(closedAt))) {
      if (filter == null || filter(item)) {
        filteredData.add(item);
      }
    }
  }

  return filteredData;
}

  void _showXReportDialog() async {
  if (currentShift == null || !currentShift!.isOpen) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Нет открытой смены. Пожалуйста, откройте смену.')),
    );
    return;
  }

  final openedAt = currentShift!.openedAt;
  final closedAt = currentShift!.closedAt ?? DateTime.now();

  // Фильтрация данных
  final sales = _filterDataByShift<ReceiptItem>(
    box: Hive.box<ReceiptItem>('receiptBox'),
    openedAt: openedAt,
    closedAt: closedAt,
  );

  final returns = _filterDataByShift<ReturnItem>(
    box: Hive.box<ReturnItem>('returnBox'),
    openedAt: openedAt,
    closedAt: closedAt,
  );

  // Калькуляция
  double totalSales = 0.0;
  double totalReturns = 0.0;
  int salesCount = sales.length;
  int returnsCount = returns.length;
  Map<String, double> paymentMethodsTotal = {
    'cash': 0.0,
    'card': 0.0,
    'qr': 0.0,
  };
  Map<String, double> returnsByMethod = {
    'cash': 0.0,
    'card': 0.0,
    'qr': 0.0,
  };

  double calculateCashInDrawer() {
  return currentShift!.initialCash + // Наличные при открытии смены
         currentShift!.totalCashAdded - // Сумма внесений
         currentShift!.totalCashWithdrawn + // Сумма изъятий
         paymentMethodsTotal['cash']! - // Продажи за наличные
         returnsByMethod['cash']!; // Возвраты за наличные
}

//Для продаж
  for (var receipt in sales) {
    totalSales += receipt.totalAmount;
    final methodName = receipt.paymentMethod.name; // Преобразуем PaymentMethod в String
        if (paymentMethodsTotal.containsKey(methodName)) {
      paymentMethodsTotal[methodName] =
          (paymentMethodsTotal[methodName] ?? 0) + receipt.totalAmount;
    } else {
      paymentMethodsTotal[methodName] = receipt.totalAmount;
    }
  }
  //Для возвратов
  for (var returnItem in returns) {
    totalReturns += returnItem.items.fold(
        0.0, (sum, item) => sum + (item.quantity * item.price2));
    final methodName = returnItem.paymentMethod.name; // Returns include a payment method
    if (returnsByMethod.containsKey(methodName)) {
      returnsByMethod[methodName] =
          (returnsByMethod[methodName] ?? 0) + returnItem.items.fold(
              0.0, (sum, item) => sum + (item.quantity * item.price2));
    } else {
      returnsByMethod[methodName] = returnItem.items.fold(
          0.0, (sum, item) => sum + (item.quantity * item.price2));
    }
  }

  final netTotal = totalSales - totalReturns;
  final cashInDrawer = calculateCashInDrawer(
  );
  // Отображение диалога
  final now = DateTime.now(); // Текущие дата и время
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Х-отчёт'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата и время: ${now.toString()}'),
            Text('Общая сумма продаж: ${totalSales.toStringAsFixed(2)} сом'),
            Text('Общая сумма возвратов: ${totalReturns.toStringAsFixed(2)} сом'),
            Text('Итоговая сумма Выручки: ${netTotal.toStringAsFixed(2)} сом'),
            const SizedBox(height: 16),
            Text('Наличные в кассе: ${cashInDrawer.toStringAsFixed(2)} сом'),
            const SizedBox(height: 16),
            Text('Количество чеков продаж: $salesCount'),
            Text('Количество чеков возвратов: $returnsCount'),
            const SizedBox(height: 16),
            const Text('Продажи по методам оплаты:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('  - Наличные: ${paymentMethodsTotal['cash']?.toStringAsFixed(2) ?? 0.0} сом'),
            Text('  - Карта: ${paymentMethodsTotal['card']?.toStringAsFixed(2) ?? 0.0} сом'),
            Text('  - QR-код: ${paymentMethodsTotal['qr']?.toStringAsFixed(2) ?? 0.0} сом'),
            const SizedBox(height: 16),
            const Text('Возвраты по методам оплаты:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('  - Наличные: ${returnsByMethod['cash']?.toStringAsFixed(2) ?? 0.0} сом'),
            Text('  - Карта: ${returnsByMethod['card']?.toStringAsFixed(2) ?? 0.0} сом'),
            Text('  - QR-код: ${returnsByMethod['qr']?.toStringAsFixed(2) ?? 0.0} сом'),          
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      );
    },
  );
}
}
class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.label,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // Обработчик нажатия
      child: Container(
        height: 50, // Компактная высота
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.5),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
