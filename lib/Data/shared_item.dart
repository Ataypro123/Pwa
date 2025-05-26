import 'package:hive/hive.dart';
part 'shared_item.g.dart';

@HiveType(typeId: 4)
class SharedItem extends HiveObject {
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

  SharedItem({
    required this.barcode,
    required this.name,
    required this.quantity,
    required this.price,
    required this.price2,
  });
}

