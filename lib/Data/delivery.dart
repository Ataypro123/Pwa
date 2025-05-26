import 'package:hive/hive.dart';
part 'delivery.g.dart';

@HiveType(typeId: 0)
class Delivery extends HiveObject {
  @HiveField(0)
  String number;

  @HiveField(1)
  String date;

  @HiveField(2)
  String sender;

  @HiveField(3)
  String receiver;

  @HiveField(4)
  String responsible;

  @HiveField(5)
  int quantity;

  @HiveField(6)
  double totalAmount;

  @HiveField(7)
  List<DeliveryItem> items; // Встроенный список товаров

  @HiveField(8)
  bool isClosed;

  @HiveField(9)
  String? barcode; // Поле для хранения штрихкода

  Delivery({
    required this.number,
    required this.date,
    required this.sender,
    required this.receiver,
    required this.responsible,
    this.quantity = 0,
    this.totalAmount = 0.0,
    this.items = const [], // Список пустой по умолчанию
    this.isClosed = false,
    this.barcode,
  });
  Delivery clone() {
    return Delivery(
      number: number,
      date: date,
      sender: sender,
      receiver: receiver,
      responsible: responsible,
      quantity: quantity,
      totalAmount: totalAmount,
      items: items.map((item) => item.clone()).toList(), // Копируем вложенные объекты
      isClosed: isClosed,
      barcode: barcode,
    );
  }
}

@HiveType(typeId: 1)
class DeliveryItem extends HiveObject {
  @HiveField(0)
  String barcode;

  @HiveField(1)
  String name;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double price;

  @HiveField(4)
  double price2;

  DeliveryItem({
    required this.barcode,
    required this.name,
    required this.quantity,
    required this.price,
    required this.price2,
  });
  DeliveryItem clone() {
    return DeliveryItem(
      barcode: barcode,
      name: name,
      quantity: quantity,
      price: price,
      price2: price2,
    );
  }
}
