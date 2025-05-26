import 'package:hive/hive.dart';
part 'payment_method.g.dart'; // Генерируемый файл

@HiveType(typeId: 9) // Уникальный typeId для адаптера
enum PaymentMethod {
  @HiveField(0)
  cash,
  @HiveField(1)
  card,
  @HiveField(2)
  qr,
  @HiveField(3)
  debt,
}
extension PaymentMethodExtension on PaymentMethod {
  String get name {
    switch (this) {
      case PaymentMethod.cash:
        return 'Наличные';
      case PaymentMethod.card:
        return 'Безналичные';
      case PaymentMethod.qr:
        return 'По QR-коду';
     case PaymentMethod.debt:
        return 'В долг';
    }
  }

  static PaymentMethod fromName(String name) {
    switch (name) {
      case 'Наличные':
        return PaymentMethod.cash;
      case 'Безналичные':
        return PaymentMethod.card;
      case 'По QR-коду':
        return PaymentMethod.qr;
      case 'В долг':
        return PaymentMethod.debt;
      default:
        throw ArgumentError('Неизвестный метод оплаты: $name');
    }
  }
}
