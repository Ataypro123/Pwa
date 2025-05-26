import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:barcode_widget/barcode_widget.dart';
import '../../../../../Data/delivery.dart';
import '../../../../Data/shared_item.dart';

class ShowcasePage extends StatefulWidget {
final Function(List<DeliveryItem>) onAddToSharedList;

const ShowcasePage({required this.onAddToSharedList, Key? key}) : super(key: key);

  @override
  _ShowcasePageState createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  late Box<Delivery> showcaseBox;
  Delivery? selectedDelivery;
  bool showItemsView = false;

  @override
  void initState() {
    super.initState();
    _initializeShowcaseBox();
  }

  Future<void> _initializeShowcaseBox() async {
    showcaseBox = await Hive.openBox<Delivery>('showcaseBox');
    setState(() {});
  }
  
  Future<void> _addDeliveryItemsToSharedList(Delivery delivery) async {
   final key = delivery.key; // Проверяем наличие ключа
  if (key != null) {
    for (var item in delivery.items) {
      final sharedItem = SharedItem(
        barcode: item.barcode,
        name: item.name,
        quantity: item.quantity,
        price: item.price,
        price2: item.price2,
      );
      await Hive.box<SharedItem>('sharedItemsBox').add(sharedItem); // Сохраняем в Hive
    }
    await showcaseBox.delete(key); // Удаляем поставку из showcaseBox
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Поставка №${delivery.number} добавлена в общий список.')),
    );
    setState(() {}); // Обновляем интерфейс
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось удалить поставку.')),
    );
  }
}


  void _openDeliveryItems(Delivery delivery) {
    setState(() {
      selectedDelivery = delivery;
      showItemsView = true;
    });
  }

  void _goBackToDeliveries() {
    setState(() {
      showItemsView = false;
      selectedDelivery = null;
    });
  }

  Future<void> _downloadTxtFile(BuildContext context) async {
    if (selectedDelivery == null) return;

    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/delivery_${selectedDelivery!.barcode}.txt');

    String content = "Штрихкод поставки: ${selectedDelivery!.barcode}\n\nСписок товаров:\n\n";
    for (var item in selectedDelivery!.items) {
      content +=
          'Название: ${item.name}, Количество: ${item.quantity}, Цена: ${item.price}, Цена2: ${item.price2}\n';
    }

    await file.writeAsString(content);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Файл сохранен: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showItemsView
            ? 'Товары из поставки №${selectedDelivery?.number}'
            : 'Витрина поставок'),
        backgroundColor: const Color.fromRGBO(176, 106, 179, 1),
        leading: showItemsView
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToDeliveries,
              )
            : null,
        actions: showItemsView
            ? [
                IconButton(
                  icon: const Icon(Icons.print),
                  tooltip: 'Скачать файл',
                  onPressed: () async {
                    await _downloadTxtFile(context);
                  },
                ),
              ]
            : null,
      ),
      body: showItemsView ? _buildDeliveryItemsView() : _buildDeliveriesView(),
    );
  }

  Widget _buildDeliveriesView() {
    return ValueListenableBuilder<Box<Delivery>>(
      valueListenable: Hive.box<Delivery>('showcaseBox').listenable(),
      builder: (context, box, _) {
        final deliveries = box.values.toList();

        return deliveries.isEmpty
            ? const Center(
                child: Text(
                  'В витрине пока нет поставок.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )
            : ListView.builder(
                itemCount: deliveries.length,
                itemBuilder: (context, index) {
                  final delivery = deliveries[index];
                  return _buildDeliveryCard(delivery);
                },
              );
      },
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          'Поставка №${delivery.number}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата: ${delivery.date}', style: const TextStyle(fontSize: 14)),
            Text('Отправитель: ${delivery.sender}', style: const TextStyle(fontSize: 14)),
            Text('Получатель: ${delivery.receiver}', style: const TextStyle(fontSize: 14)),
          ],
        ),
        children: [
          ListTile(
            title: const Text('Ответственный'),
            subtitle: Text(delivery.responsible),
          ),
          ListTile(
            title: const Text('Количество товаров'),
            subtitle: Text('${delivery.quantity}'),
          ),
          ListTile(
            title: const Text('Общая сумма'),
            subtitle: Text('${delivery.totalAmount} сом'),
          ),
          if (delivery.items.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () => _openDeliveryItems(delivery),
                  icon: const Icon(Icons.open_in_new, color: Colors.blue),
                  label: const Text('Открыть товары'),
                ),
                TextButton.icon(
                  onPressed: () => _addDeliveryItemsToSharedList(delivery),
                  icon: const Icon(Icons.add, color: Colors.green),
                  label: const Text('Добавить в общий список'),
                ),
              ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryItemsView() {
    if (selectedDelivery == null || selectedDelivery!.items.isEmpty) {
      return const Center(
        child: Text(
          'В этой поставке нет товаров.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    final items = selectedDelivery!.items;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarcodeWidget(
            data: selectedDelivery!.barcode ?? 'Нет данных',
            barcode: Barcode.code128(),
            width: 300,
            height: 100,
            drawText: true,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(69, 104, 220, 1),
                    child: Text('${index + 1}'),
                  ),
                  title: Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text('Количество: ${item.quantity}'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Цена: ${item.price} сом'),
                      Text('Цена2: ${item.price2} сом'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
