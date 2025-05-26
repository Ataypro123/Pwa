import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../Data/shared_item.dart';

class OpenedDeliveryPage extends StatefulWidget {
  const OpenedDeliveryPage({Key? key}) : super(key: key);

  @override
  _OpenedDeliveryPageState createState() => _OpenedDeliveryPageState();
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

class _OpenedDeliveryPageState extends State<OpenedDeliveryPage> {
  late Box<SharedItem> sharedItemsBox;
  late List<SharedItem> items;
  @override
  void initState() {
    super.initState();
    sharedItemsBox = Hive.box<SharedItem>('sharedItemsBox');
    items = sharedItemsBox.values.toList();
  }

  // Сохранение изменений
  void _saveChanges() {
    for (var item in items) {
      item.save();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Изменения сохранены')),
    );

    // Переход на MainPage
    Navigator.pushReplacementNamed(context, '/');
  }

  // Подсчет общего количества товаров и общей суммы
  int _calculateTotalQuantity() {
  return sharedItemsBox.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double _calculateTotalAmount() {
  return sharedItemsBox.values.fold(0.0, (sum, item) => sum + (item.quantity * item.price2));
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
        items[existingIndex].save();
      } else {
        final newItem = SharedItem(
          barcode: barcode,
          name: name,
          quantity: quantity,
          price: price,
          price2: price2,
        );
        items.add(newItem);
        sharedItemsBox.add(newItem);
      }
    });
  }

  // Удаление товара
  Future<void> _removeItem(int index) async {
    final confirm = await _showConfirmationDialog(index);
    if (confirm) {
      setState(() {
        final item = items.removeAt(index);
        item.delete();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Витрина товаров'),
        backgroundColor: const Color.fromRGBO(176, 106, 179, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'Действия с витриной',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Добавить товар'),
              onTap: _showAddItemDialog,
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Сканировать QR-код'),
              onTap: _scanQRCode,
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Загрузить из файла'),
              onTap: _loadExcelFile,
            ),
          ],
        ),
      ),
      body: ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return GestureDetector(
      onTap: () => _showEditItemDialog(item, index),
      child:Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Номенклатура: ${item.barcode}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  'Кол-во: ${item.quantity}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Цена1: ${item.price.toStringAsFixed(2)} сом',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text(
                  'Цена2: ${item.price2.toStringAsFixed(2)} сом',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeItem(index),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  },
)
    );
  }
Future<void> _showEditItemDialog(SharedItem item, int index) async {
  final barcodeController = TextEditingController(text: item.barcode);
  final nameController = TextEditingController(text: item.name);
  final quantityController = TextEditingController(text: item.quantity.toString());
  final priceController = TextEditingController(text: item.price.toStringAsFixed(2));
  final price2Controller = TextEditingController(text: item.price2.toStringAsFixed(2));

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Редактировать товар'),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedBarcode = barcodeController.text.trim();
              final updatedName = nameController.text.trim();
              final updatedQuantity = int.tryParse(quantityController.text) ?? 0;
              final updatedPrice = double.tryParse(priceController.text) ?? 0.0;
              final updatedPrice2 = double.tryParse(price2Controller.text) ?? 0.0;

              if (updatedBarcode.isEmpty || updatedName.isEmpty || updatedQuantity <= 0 || updatedPrice <= 0.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Заполните все поля корректно')),
                );
                return;
              }

              setState(() {
                final updatedItem = item
                  ..barcode = updatedBarcode
                  ..name = updatedName
                  ..quantity = updatedQuantity
                  ..price = updatedPrice
                  ..price2 = updatedPrice2;
                updatedItem.save();
                items[index] = updatedItem;
              });

              Navigator.of(context).pop();
            },
            child: const Text('Сохранить'),
          ),
        ],
      );
    },
  );
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
}
