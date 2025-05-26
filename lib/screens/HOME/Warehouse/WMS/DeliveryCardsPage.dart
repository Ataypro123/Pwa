import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeliveryCardsPage extends StatefulWidget {
  static final List<Map<String, dynamic>> _deliveries = [];

  // Метод для добавления новых поставок
  static void addDelivery(Map<String, dynamic> delivery) {
    _deliveries.add(delivery);
    Hive.box('storageUnitBox').add(delivery); // Сохраняем в Hive
  }

  @override
  _DeliveryCardsPageState createState() => _DeliveryCardsPageState();
}

class _DeliveryCardsPageState extends State<DeliveryCardsPage> {
  @override
  void initState() {
    super.initState();
    _loadDeliveriesFromHive();
  }

  Future<void> _loadDeliveriesFromHive() async {
    final box = Hive.box('storageUnitBox');
    setState(() {
      DeliveryCardsPage._deliveries.clear();
      DeliveryCardsPage._deliveries.addAll(
        box.values.map((delivery) => (delivery as Map<String, dynamic>)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: DeliveryCardsPage._deliveries.length,
      itemBuilder: (context, index) {
        final delivery = DeliveryCardsPage._deliveries[index];
        return DeliveryItem(delivery: delivery);
      },
    );
  }
}

class DeliveryItem extends StatelessWidget {
  final Map<String, dynamic> delivery;

  const DeliveryItem({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        title: Text('Поставка №${delivery['number']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата: ${delivery['date']}'),
            Text('Отправитель: ${delivery['sender']}'),
            Text('Получатель: ${delivery['receiver']}'),
            Text('Ответственный: ${delivery['responsible']}'),
            Text('Количество товаров: ${delivery['quantity']}'),
            Text('Сумма: ${delivery['totalAmount']} сом'),
          ],
        ),
      ),
    );
  }
}
