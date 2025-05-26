import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../Data/warehouse.dart';
import 'WMS/WMS.dart';

class WarehouseSelectionPage extends StatefulWidget {
  @override
  _WarehouseSelectionPageState createState() => _WarehouseSelectionPageState();
}

class _WarehouseSelectionPageState extends State<WarehouseSelectionPage> {
  late Box<Warehouse> warehouseBox;

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    warehouseBox = await Hive.openBox<Warehouse>('warehouseBox');
    setState(() {});
  }

  Future<void> _createNewWarehouse() async {
    final TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Создать новый склад'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Название склада',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final warehouseName = nameController.text.trim();
                if (warehouseName.isNotEmpty) {
                  final warehouse = Warehouse(
                    id: const Uuid().v4(),
                    name: warehouseName,
                  );
                  warehouseBox.add(warehouse);
                  setState(() {});
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Название склада не может быть пустым')),
                  );
                }
              },
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteWarehouse(Warehouse warehouse) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Подтвердите удаление'),
              content: Text('Вы уверены, что хотите удалить склад "${warehouse.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Удалить'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      await warehouse.delete();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Склад "${warehouse.name}" удалён.')),
      );
    }
  }

  void _enterWarehouse(Warehouse warehouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WMSPage(warehouse: warehouse),
      ),
    );
  }

  Future<void> _changeCardColor(Warehouse warehouse) async {
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выберите цвет для склада'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildColorOption(Colors.blue),
              _buildColorOption(Colors.green),
              _buildColorOption(Colors.orange),
              _buildColorOption(Colors.purple),
              _buildColorOption(Colors.red),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );

    if (selectedColor != null) {
      warehouse.color = selectedColor.value;
      await warehouse.save();
      setState(() {});
    }
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор склада'),
        backgroundColor: const Color.fromRGBO(69, 104, 220, 1)
      ),
      body: ValueListenableBuilder<Box<Warehouse>>(
        valueListenable: Hive.box<Warehouse>('warehouseBox').listenable(),
        builder: (context, box, _) {
          final warehouses = box.values.toList();

          return warehouses.isEmpty
              ? const Center(
                  child: Text(
                    'Нет созданных складов.\nНажмите "+" для добавления.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3 / 2,
                    ),
                    itemCount: warehouses.length,
                    itemBuilder: (context, index) {
                      final warehouse = warehouses[index];
                      return Card(
                        color: Color(warehouse.color),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () => _enterWarehouse(warehouse),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.warehouse,
                                      size: 48,
                                      color: Colors.blueAccent,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      warehouse.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.color_lens,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _changeCardColor(warehouse),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteWarehouse(warehouse),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewWarehouse,
        label: const Text('Добавить склад'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
