import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Data/shift_status.dart';

class CloseShiftPage extends StatefulWidget {
  final double totalSales;
  final double totalReturns;
  final Map<String, double> salesByMethod;
  final Map<String, double> returnsByMethod;
  final double cashInDrawer;
  final double cashDeposits;
  final double cashWithdrawals;

  const CloseShiftPage({
    Key? key,
    required this.totalSales,
    required this.totalReturns,
    required this.salesByMethod,
    required this.returnsByMethod,
    required this.cashInDrawer,
    required this.cashDeposits,
    required this.cashWithdrawals,
  }) : super(key: key);

  @override
  _CloseShiftPageState createState() => _CloseShiftPageState();
}

class _CloseShiftPageState extends State<CloseShiftPage> {
  // Controllers for form inputs
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _withdrawalController = TextEditingController();
  final Map<String, TextEditingController> _salesControllers = {};
  final Map<String, TextEditingController> _returnsControllers = {};

  double enteredCash = 0.0;
  double enteredDeposits = 0.0;
  double enteredWithdrawals = 0.0;

  @override
  void initState() {
    super.initState();
    _cashController.text = widget.cashInDrawer.toStringAsFixed(2);
    _depositController.text = widget.cashDeposits.toStringAsFixed(2);
    _withdrawalController.text = widget.cashWithdrawals.toStringAsFixed(2);

    // Initialize controllers for sales and returns
    widget.salesByMethod.forEach((key, value) {
      _salesControllers[key] = TextEditingController();
    });
    widget.returnsByMethod.forEach((key, value) {
      _returnsControllers[key] = TextEditingController();
    });
  }

  void onFieldChanged(String value, Function(double) updateFunction) {
    try {
      updateFunction(double.tryParse(value) ?? 0.0);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Введите корректное число',
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  // Calculate total cash on hand
  double get totalCashOnHand =>
      enteredCash + enteredDeposits - enteredWithdrawals;

  // Close shift button handler
  void _closeShift() async {
  bool allInputsValid = true;

  // Check cash, deposits, and withdrawals
  if (enteredCash != widget.cashInDrawer ||
      enteredDeposits != widget.cashDeposits ||
      enteredWithdrawals != widget.cashWithdrawals) {
    allInputsValid = false;
  }

  // Check sales by method
  for (var entry in _salesControllers.entries) {
    final controllerValue = double.tryParse(entry.value.text);
    if (controllerValue == null || controllerValue != widget.salesByMethod[entry.key]) {
      allInputsValid = false;
      break;
    }
  }

  // Check returns by method
  for (var entry in _returnsControllers.entries) {
    final controllerValue = double.tryParse(entry.value.text);
    if (controllerValue == null || controllerValue != widget.returnsByMethod[entry.key]) {
      allInputsValid = false;
      break;
    }
  }

  if (allInputsValid) {
    // Save shift closure details in Hive
    try {
      // Open the Hive Box with the correct type
      final box = await Hive.openBox<ShiftStatus>('shiftStatusBox');

      // Find the last open shift
      final lastOpenShift = box.values.lastWhere(
  (shift) => shift.isOpen,
  orElse: () => ShiftStatus(
    shiftId: '',
    isOpen: false,
    openedAt: DateTime.now(),
    closedAt: DateTime.now(),
    initialCash: 0.0,
    totalCashAdded: 0.0,
    totalCashWithdrawn: 0.0,
  ),
);


      if (lastOpenShift != null) {
        // Update the last open shift
        lastOpenShift 
          ..isOpen = false
          ..closedAt = DateTime.now()
          ..save();
      } else {
        // No open shift found, create a new record (optional fallback)
        box.add(ShiftStatus(
          shiftId: DateTime.now().millisecondsSinceEpoch.toString(),
          isOpen: false,
          openedAt: DateTime.now(),
          closedAt: DateTime.now(),
          initialCash: widget.cashInDrawer,
          totalCashAdded: widget.cashDeposits,
          totalCashWithdrawn: widget.cashWithdrawals,
        ));
      }

      Fluttertoast.showToast(
        msg: 'Смена закрыта успешно!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Ошибка при сохранении данных: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } else {
    Fluttertoast.showToast(
      msg: 'Проверьте введенные данные!',
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Закрытие смены'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Введите данные для закрытия смены:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DataTable(
              columns: const [
                DataColumn(label: Text('Тип')),
                DataColumn(label: Text('Система')),
                DataColumn(label: Text('Ввод')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('Наличные')),
                  DataCell(Text(widget.cashInDrawer.toStringAsFixed(2))),
                  DataCell(TextFormField(
                    controller: _cashController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Введите сумму',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => onFieldChanged(value, (newValue) {
                      setState(() {
                        enteredCash = newValue;
                      });
                    }),
                  )),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Внесение наличных')),
                  DataCell(Text(widget.cashDeposits.toStringAsFixed(2))),
                  DataCell(TextFormField(
                    controller: _depositController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Введите сумму',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => onFieldChanged(value, (newValue) {
                      setState(() {
                        enteredDeposits = newValue;
                      });
                    }),
                  )),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Изъятие наличных')),
                  DataCell(Text(widget.cashWithdrawals.toStringAsFixed(2))),
                  DataCell(TextFormField(
                    controller: _withdrawalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Введите сумму',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => onFieldChanged(value, (newValue) {
                      setState(() {
                        enteredWithdrawals = newValue;
                      });
                    }),
                  )),
                ]),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Продажи по видам оплат:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...widget.salesByMethod.entries.map((entry) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 3, child: Text(entry.key)),
                  Expanded(
                    flex: 3,
                    child: Text(entry.value.toStringAsFixed(2)),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _salesControllers[entry.key],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Введите сумму',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 10),
            const Text(
              'Возвраты по видам оплат:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...widget.returnsByMethod.entries.map((entry) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 3, child: Text(entry.key)),
                  Expanded(
                    flex: 3,
                    child: Text(entry.value.toStringAsFixed(2)),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _returnsControllers[entry.key],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Введите сумму',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 20),
            // Summary Section
            const Divider(),
            const Text(
              'Общий итог:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Общая сумма продаж: ${widget.totalSales.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Общая сумма возвратов: ${widget.totalReturns.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Сумма на кассе: ${totalCashOnHand.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _closeShift,
              child: const Text('Закрыть смену'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
