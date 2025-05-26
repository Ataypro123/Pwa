import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../../../../Data/delivery.dart';
import 'ItemListPage.dart';
// Для веба

class EditDeliveryPage extends StatefulWidget {
  final Delivery delivery;
  final String deliveryBarcode;

  const EditDeliveryPage({
    required this.delivery,
    required this.deliveryBarcode,
    Key? key,
  }) : super(key: key);

  @override
  _EditDeliveryPageState createState() => _EditDeliveryPageState();
}
class ExcelConfig {
  final int startRow;
  final int barcodeColumn;
  final int nameColumn;
  final int quantityColumn;
  final int priceColumn;
  final int price2Column;
  final bool ignoreInvalidRows;

  ExcelConfig({
    required this.startRow,
    required this.barcodeColumn,
    required this.nameColumn,
    required this.quantityColumn,
    required this.priceColumn,
    required this.price2Column,
    required this.ignoreInvalidRows,
  });
}

class _EditDeliveryPageState extends State<EditDeliveryPage> {
  late List<DeliveryItem> items;
  late String barcode;
  late TextEditingController senderController;
  late TextEditingController receiverController;
  late TextEditingController responsibleController;

  final TextEditingController statusController = TextEditingController();
  String deliveryStatus = 'в обработке';
  bool _isPrinterPressed = false; // Флаг для проверки нажатия кнопки принтера
  bool isPrinterPressed = false;
  bool isReadOnly = false;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.delivery.items);
    barcode = widget.deliveryBarcode;
    senderController = TextEditingController(text: widget.delivery.sender);
    receiverController = TextEditingController(text: widget.delivery.receiver);
    responsibleController = TextEditingController(text: widget.delivery.responsible);
    statusController.text = deliveryStatus;
    isReadOnly = widget.delivery.isClosed;
  }
  void _initializeBoxes() async {
  await Hive.openBox<DeliveryItem>('itemBox');
  await Hive.openBox<Delivery>('deliveryBox');
}


  @override
  void dispose() {
    _saveChanges();
    senderController.dispose();
    receiverController.dispose();
    responsibleController.dispose();
    statusController.dispose();
    super.dispose();
  }

  // Сохранение изменений в Hive
  void _saveChanges() {
    widget.delivery
      ..sender = senderController.text
      ..receiver = receiverController.text
      ..responsible = responsibleController.text
      ..items = items;

    _updateDeliveryData();
    widget.delivery.save();
    Navigator.of(context).pop(widget.delivery);
  }

  // Обновление данных поставки
  void _updateDeliveryData() {
    setState(() {
      widget.delivery.quantity = items.fold(0, (sum, item) => sum + item.quantity);
      widget.delivery.totalAmount = items.fold(0.0, (sum, item) => sum + (item.quantity * item.price));
    });
  }

  // Изменение статуса поставки
  void _changeStatus(String newStatus) {
    setState(() {
      deliveryStatus = newStatus;
      statusController.text = newStatus;
    });
  }

  // Закрытие поставки
  void _closeDelivery() {
    setState(() {
      widget.delivery.isClosed = true;
      isReadOnly = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Поставка успешно закрыта')),
    );
  }

  // Добавление или обновление товара
  void _addOrUpdateItem(String barcode, String name, int quantity, double price, double price2) {
    setState(() {
      final existingIndex = items.indexWhere((item) => item.barcode == barcode);

      if (existingIndex != -1) {
        items[existingIndex]
          ..quantity += quantity
          ..price = price
          ..price2 = price2;
      } else {
        items.add(DeliveryItem(
          barcode: barcode,
          name: name,
          quantity: quantity,
          price: price,
          price2: price2,
        ));
      }
      _updateDeliveryData();
    });
  }

  // Удаление товара
  Future<void> _removeItem(int index) async {
    final confirm = await _showConfirmationDialog(index);
    if (confirm) {
      setState(() {
        items.removeAt(index);
        _updateDeliveryData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар удалён')),
      );
    }
  }

    
Future<ExcelConfig?> _showExcelConfigDialog() async {
  final startRowController = TextEditingController(text: '2');
  final barcodeColumnController = TextEditingController(text: '1');
  final nameColumnController = TextEditingController(text: '0');
  final quantityColumnController = TextEditingController(text: '2');
  final priceColumnController = TextEditingController(text: '3');
  final price2ColumnController = TextEditingController(text: '4');
  bool ignoreInvalidRows = true;

  return showDialog<ExcelConfig>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Настройки импорта'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(startRowController, 'Номер строки начала данных', TextInputType.number),
              _buildTextField(barcodeColumnController, 'Столбец штрих-кода', TextInputType.number),
              _buildTextField(nameColumnController, 'Столбец названия', TextInputType.number),
              _buildTextField(quantityColumnController, 'Столбец количества', TextInputType.number),
              _buildTextField(priceColumnController, 'Столбец цены', TextInputType.number),
              _buildTextField(price2ColumnController, 'Столбец цены 2', TextInputType.number),
              CheckboxListTile(
                title: const Text('Игнорировать строки с ошибками'),
                value: ignoreInvalidRows,
                onChanged: (value) => ignoreInvalidRows = value ?? true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(ExcelConfig(
                startRow: int.tryParse(startRowController.text) ?? 2,
                barcodeColumn: int.tryParse(barcodeColumnController.text) ?? 1,
                nameColumn: int.tryParse(nameColumnController.text) ?? 0,
                quantityColumn: int.tryParse(quantityColumnController.text) ?? 2,
                priceColumn: int.tryParse(priceColumnController.text) ?? 3,
                price2Column: int.tryParse(price2ColumnController.text) ?? 4,
                ignoreInvalidRows: ignoreInvalidRows,
              ));
            },
            child: const Text('Применить'),
          ),
        ],
      );
    },
  );
}

  // Загрузка товаров из Excel файла
  Future<void> _loadExcelFile() async {
  final config = await _showExcelConfigDialog();
  if (config == null) return; // Если настройки не заданы, выходим.

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'xls'],
  );

  if (result != null) {
    final fileBytes = result.files.single.bytes;
    if (fileBytes != null) {
      final excel = Excel.decodeBytes(fileBytes);
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet != null) {
          for (var row in sheet.rows.skip(config.startRow - 1)) {
            final barcode = row[config.barcodeColumn]?.value?.toString();
            final name = row[config.nameColumn]?.value?.toString();
            final quantity = int.tryParse(row[config.quantityColumn]?.value?.toString() ?? '');
            final price = double.tryParse(row[config.priceColumn]?.value?.toString() ?? '');
            final price2 = double.tryParse(row[config.price2Column]?.value?.toString() ?? '');

            if (!config.ignoreInvalidRows &&
                (barcode == null || name == null || quantity == null || price == null || price2 == null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Пропущены обязательные данные в строке')),
              );
              continue;
            }

            if (barcode != null && name != null && quantity != null && price != null && price2 != null) {
              _addOrUpdateItem(barcode, name, quantity, price, price2);
            }
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товары добавлены из файла')),
      );
    }
  }
}

  // Сканирование QR-кода
// Future<void> _scanQRCode(BuildContext context) async {
//   if (!kIsWeb) {
//     // Сканирование для мобильных платформ
//     await BarcodeScanner.scan();
//   } else {
//     // Веб
//     final scannedCode = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => WebBarcodeScanner()),
//     );

//     if (scannedCode != null && scannedCode.isNotEmpty) {
//       _addOrUpdateItem(scannedCode, '', 1, 0.0, 0.0);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Товар добавлен')),
//       );
//     }
//   }
// }


  Future<void> _scanQRCode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        _addOrUpdateItem(result.rawContent, '', 1, 0.0, 0.0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар добавлен')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сканирования: $e')),
      );
    }
  }

  // Диалог подтверждения
  Future<bool> _showConfirmationDialog(int index) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Подтвердите удаление'),
              content: Text('Удалить товар "${items[index].name}"?'),
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
        ) ??
        false;
  }

  // Диалог добавления товара
  Future<void> _showAddItemDialog() async {
    final barcodeController = TextEditingController();
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final price2Controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить товар'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(barcodeController, 'Номенклатура товара'),
              _buildTextField(nameController, 'Название товара'),
              _buildTextField(quantityController, 'Количество', TextInputType.number),
              _buildTextField(priceController, '1.Цена себестоимости', TextInputType.number),
              _buildTextField(price2Controller, '2.Цена планируемой продажи', TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
            TextButton(
              onPressed: () {
                final barcode = barcodeController.text.trim();
                final name = nameController.text.trim();
                final quantity = int.tryParse(quantityController.text) ?? 0;
                final price = double.tryParse(priceController.text) ?? 0.0;
                final price2 = double.tryParse(price2Controller.text) ?? 0.0;

                if (barcode.isEmpty || name.isEmpty || quantity <= 0 || price <= 0.0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заполните все поля корректно')),
                  );
                  return;
                }

                _addOrUpdateItem(barcode, name, quantity, price, price2);
                Navigator.of(context).pop();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  // Поле ввода
  Widget _buildTextField(TextEditingController controller, String label, [TextInputType inputType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: inputType,
      ),
    );
  }
  

  // Открытие поставки с проверкой пароля
void _openDelivery(String password) async {

}

// Диалог для ввода текста (универсальный)
Future<void> _showInputDialog({
  required BuildContext context,
  required String title,
  required String labelText,
  required Function(String) onSubmit,
}) async {
  final textController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
          obscureText: true, // Для ввода пароля
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final inputText = textController.text.trim();
              onSubmit(inputText);
              Navigator.of(context).pop();
            },
            child: const Text('ОК'),
          ),
        ],
      );
    },
  );
}

  // Показать диалог открытия поставки
Future<void> _showOpenDeliveryDialog() async {
  await _showInputDialog(
    context: context,
    title: 'Введите пароль для открытия поставки',
    labelText: 'Пароль',
    onSubmit: _openDelivery,
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.delivery.isClosed
              ? 'Поставка №${widget.delivery.number} (Закрыта)'
              : 'Редактировать поставку №${widget.delivery.number}'),
          const SizedBox(height: 4),
          Text(
            'Статус: $deliveryStatus',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed:  () async {
            // Изменяем статус на "доставляется"
            _changeStatus('доставляется');

            // Открываем новый экран с передачей списка товаров
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemListPage(items: items, deliveryBarcode: barcode, // Передаем штрихкод
                ),
                
              ),
            );

            // Устанавливаем флаг нажатия кнопки принтера
            setState(() {
              _isPrinterPressed = true;
            });
          },
        ),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color.fromRGBO(69, 104, 220, 1)),
              
              child: Text(widget.delivery.isClosed ? 'Закрытая поставка' : 'Действия с поставкой',
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
            ),
            if (!widget.delivery.isClosed)
              ListTile(leading: const Icon(Icons.add_box), title: const Text('Добавить товар'), onTap: _showAddItemDialog),
            if (!widget.delivery.isClosed)
              ListTile(leading: const Icon(Icons.qr_code_scanner), title: const Text('Сканировать QR-код'), onTap: () async {await _scanQRCode();},),
            if (!widget.delivery.isClosed)
              ListTile(leading: const Icon(Icons.upload_file), title: const Text('Загрузить из файла'), onTap: _loadExcelFile),
           if (widget.delivery.isClosed)
              ListTile(
                leading: const Icon(Icons.lock_open),
                title: const Text('Открыть поставку'),
                onTap: _showOpenDeliveryDialog,
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text('Общее количество: ${widget.delivery.quantity}'),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: Text('Общая сумма: ${widget.delivery.totalAmount.toStringAsFixed(2)} сом'),
            ),
            Divider(),
          ListTile(
  leading: Icon(widget.delivery.isClosed ? Icons.lock : Icons.close),
            title: Text(widget.delivery.isClosed ? 'Поставка закрыта' : 'Закрыть поставку'),
            onTap: widget.delivery.isClosed
                ? null // Действие недоступно для закрытой поставки
                : _isPrinterPressed
                    ? _closeDelivery
                    : () {
          // Показать предупреждение
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Внимание'),
                content: Text('Сначала распечатайте накладную!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Закрыть диалог
                    },
                    child: Text('ОК'),
                  ),
                ],
              );
            },
          );
        },
),
          ],
        ),
      ),
      body: items.isEmpty
          ? const Center(child: Text('Список товаров пуст.'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                        'Номенкулатура: ${item.barcode}, Количество: ${item.quantity}, Цена1: ${item.price} сом, Цена2: ${item.price2} сом'),
                    trailing: isReadOnly
                        ? null
                        : IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeItem(index)),
                  ),
                );
              },
            ),
            
    );
  }
}
