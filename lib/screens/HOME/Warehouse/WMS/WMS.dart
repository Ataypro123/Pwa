import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../Data/delivery.dart';
import '../../../../Data/warehouse.dart';
import 'Edit_delivery_page.dart';

class WMSPage extends StatefulWidget {
  final Warehouse warehouse;

  const WMSPage({required this.warehouse, Key? key}) : super(key: key);

  @override
  _WMSPageState createState() => _WMSPageState();
}

class _WMSPageState extends State<WMSPage> {
  int? selectedDeliveryIndex; // Индекс выбранной поставки
  late Box<Delivery> deliveryBox;
  late List<Delivery> deliveries = [];
  late List<Delivery> filteredDeliveries = []; // Для отображения отфильтрованных данных
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeBoxes();
    _searchController.addListener(_filterDeliveries);
  }

  Future<void> _initializeBoxes() async {
    deliveryBox = await Hive.openBox<Delivery>(widget.warehouse.deliveryBoxName);
    setState(() {
      deliveries = deliveryBox.values.toList();
      filteredDeliveries = deliveries; // Изначально показываем все данные
    });
  }

  void _filterDeliveries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDeliveries = deliveries.where((delivery) {
        return delivery.number.contains(query) ||
            delivery.sender.toLowerCase().contains(query) ||
            delivery.receiver.toLowerCase().contains(query) ||
            delivery.responsible.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showCreateDeliveryDialog() async {
    final barcode = Uuid().v4(); // Генерация уникального штрихкода
    final newDelivery = await showDialog<Delivery>(
      context: context,
      builder: (BuildContext context) {
        return CreateDeliveryDialog(barcode: barcode);
      },
    );

    if (newDelivery != null) {
      await deliveryBox.add(newDelivery);
      setState(() {
        deliveries = deliveryBox.values.toList();
        filteredDeliveries = deliveries;
      });
    }
  }

  void _updateDelivery(int index, Delivery updatedDelivery) async {
    final key = deliveryBox.keyAt(index);
    if (key != null) {
      await deliveryBox.put(key, updatedDelivery);
      setState(() {
        deliveries[index] = updatedDelivery;
        filteredDeliveries = deliveries;
      });
    }
  }

  Future<void> _showMoveDeliveryDialog() async {
    if (selectedDeliveryIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите одну поставку для перемещения.')),
      );
      return;
    }

    final selectedDelivery = filteredDeliveries[selectedDeliveryIndex!];

    final box = await Hive.openBox<Warehouse>('warehouseBox');
    final warehouses = box.values.toList();

    if (warehouses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет доступных складов для перемещения.')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Переместить выбранную поставку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: warehouses.map((warehouse) {
              if (warehouse.id != widget.warehouse.id) {
                return ListTile(
                  title: Text(warehouse.name),
                  onTap: () async {
                    await _moveDeliveryToAnotherWarehouse(selectedDelivery, warehouse);
                    Navigator.of(context).pop();
                  },
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
        );
      },
    );
  }

Future<void> _moveDeliveryToAnotherWarehouse(
    Delivery delivery, Warehouse targetWarehouse) async {
  final targetBox = await Hive.openBox<Delivery>(targetWarehouse.deliveryBoxName);

  // Создаем копию объекта
  final copiedDelivery = Delivery(
    number: delivery.number,
    date: delivery.date,
    sender: delivery.sender,
    receiver: delivery.receiver,
    responsible: delivery.responsible,
    barcode: delivery.barcode,
    quantity: delivery.quantity,
    totalAmount: delivery.totalAmount,
    items: delivery.items, // Копируем вложенные элементы, если есть
    isClosed: delivery.isClosed,
  );

  await targetBox.add(copiedDelivery); // Добавляем копию в целевой бокс
  await deliveryBox.delete(delivery.key); // Удаляем оригинал из текущего бокса

  setState(() {
    deliveries = deliveryBox.values.toList();
    filteredDeliveries = deliveries;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Поставка перемещена в склад "${targetWarehouse.name}".')),
  );
}


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            backgroundColor: const Color.fromRGBO(69, 104, 220, 1),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Управление складом ${widget.warehouse.name}',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(69, 104, 220, 1), Color.fromRGBO(176, 106, 179, 1)],
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
                        _buildActionButton(Icons.add, 'Создать новую поставку', _showCreateDeliveryDialog),
                        _buildActionButton(Icons.arrow_forward, 'Перемещение поставки', _showMoveDeliveryDialog),
                        _buildActionButton(Icons.last_page, 'Переместить в витрину', _showMoveToShowcaseDialog),
                      ],
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSearchBar(),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredDeliveries.length,
                  itemBuilder: (context, index) {
                    final delivery = filteredDeliveries[index];
                    return DeliveryItem(
                      delivery: delivery,
                      index: index,
                      selectedIndex: selectedDeliveryIndex,
                      onSelected: (selectedIndex) {
                        setState(() {
                          selectedDeliveryIndex = selectedIndex;
                        });
                      },
                      onEdit: (updatedDelivery) {
                        _updateDelivery(index, updatedDelivery);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Поиск поставки',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

Future<void> _showMoveToShowcaseDialog() async {
  if (selectedDeliveryIndex == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выберите поставку для перемещения в витрину.')),
    );
    return;
  }

  final selectedDelivery = filteredDeliveries[selectedDeliveryIndex!];
  final showcaseBox = await Hive.openBox<Delivery>('showcaseBox');

  // Создаем копию объекта
  final copiedDelivery = Delivery(
    number: selectedDelivery.number,
    date: selectedDelivery.date,
    sender: selectedDelivery.sender,
    receiver: selectedDelivery.receiver,
    responsible: selectedDelivery.responsible,
    barcode: selectedDelivery.barcode,
    quantity: selectedDelivery.quantity,
    totalAmount: selectedDelivery.totalAmount,
    items: selectedDelivery.items, // Копируем вложенные элементы
    isClosed: selectedDelivery.isClosed,
  );

  await showcaseBox.add(copiedDelivery); // Добавляем копию в витрину
  await deliveryBox.delete(selectedDelivery.key); // Удаляем оригинал из текущего бокса

  setState(() {
    deliveries = deliveryBox.values.toList();
    filteredDeliveries = deliveries;
    selectedDeliveryIndex = null; // Сбрасываем выбор
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Поставка перемещена в витрину.')),
  );
}




}

class CreateDeliveryDialog extends StatefulWidget {
  final String barcode;

  const CreateDeliveryDialog({required this.barcode});

  @override
  _CreateDeliveryDialogState createState() => _CreateDeliveryDialogState();
}

class _CreateDeliveryDialogState extends State<CreateDeliveryDialog> {
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _responsibleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать новую поставку'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _senderController,
            decoration: const InputDecoration(labelText: 'Контрагент или отправитель'),
          ),
          TextField(
            controller: _receiverController,
            decoration: const InputDecoration(labelText: 'Склад получатель'),
          ),
          TextField(
            controller: _responsibleController,
            decoration: const InputDecoration(labelText: 'Ответственный за поставку'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            final newDelivery = Delivery(
              number: DateTime.now().millisecondsSinceEpoch.toString(),
              date: DateTime.now().toIso8601String(),
              sender: _senderController.text.trim(),
              receiver: _receiverController.text.trim(),
              responsible: _responsibleController.text.trim(),
              barcode: widget.barcode,
            );
            Navigator.of(context).pop(newDelivery);
          },
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

class DeliveryItem extends StatelessWidget {
  final Delivery delivery;
  final int index;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<Delivery> onEdit;

  const DeliveryItem({
    required this.delivery,
    required this.index,
    required this.selectedIndex,
    required this.onSelected,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Radio<int>(
          value: index,
          groupValue: selectedIndex,
          onChanged: (int? value) {
            if (value != null) {
              onSelected(value);
            }
          },
        ),
        title: Text('Поставка №${delivery.number}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата: ${delivery.date}'),
            Text('Отправитель: ${delivery.sender}'),
            Text('Получатель: ${delivery.receiver}'),
            Text('Ответственный: ${delivery.responsible}'),
          ],
        ),
        trailing: const Icon(Icons.edit),
        onTap: () async {
          final updatedDelivery = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditDeliveryPage(
                delivery: delivery,
                deliveryBarcode: delivery.barcode ?? 'Нет штрихкода',
              ),
            ),
          );

          if (updatedDelivery != null) {
            onSelected(index);
          }
        },
      ),
    );
  }
}
