import 'package:hive/hive.dart';
import 'shared_item.dart'; // Подключение модели SharedItem для хранения данных товаров
import 'payment_method.dart';
part 'receipt_item.g.dart';

@HiveType(typeId: 5)
class ReceiptItem extends HiveObject {
  @HiveField(0)
  String receiptNumber; // Номер чека

  @HiveField(1)
  List<SharedItem> items; // Список товаров в чеке

  @HiveField(2)
  double totalAmount; // Итоговая сумма

  @HiveField(3)
  PaymentMethod paymentMethod; // Используем enum

  @HiveField(4)
  DateTime createdAt; // Дата и время создания чека

  @HiveField(5)
  String? comment; // Комментарий к чеку

  @HiveField(6) // Добавляем новое поле
  bool isDeleted;

  @HiveField(7)
  bool hasReturn; // Указывает, был ли произведён возврат для этого чека

  ReceiptItem({
    required this.receiptNumber,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    this.comment,
    this.isDeleted = false, // По умолчанию чек не удалён
    this.hasReturn = false, // По умолчанию возврат не производился

  });
}
@HiveType(typeId: 6) // Укажите уникальный typeId для модели должников
class DebtorItem extends HiveObject {
  @HiveField(0)
  final String receiptNumber;

  @HiveField(1)
  final List<SharedItem> items; // Список товаров, связанных с долгом

  @HiveField(2)
  final double totalAmount; // Общая сумма долга

  @HiveField(3)
  final String debtorName; // Имя и фамилия должника

  @HiveField(4)
  final String debtorPhone; // Телефон должника

  @HiveField(5)
   String paymentMethod; // Способ оплаты

  @HiveField(6)
  final DateTime createdAt; // Дата создания чека

  @HiveField(7)
  final DateTime returnDate; // Дата возврата

  @HiveField(8)
  final String? comment; // Необязательный комментарий

  DebtorItem({
    required this.receiptNumber,
    required this.items,
    required this.totalAmount,
    required this.debtorName,
    required this.debtorPhone,
    required this.paymentMethod,
    required this.createdAt,
    required this.returnDate,
    this.comment,
  });
}
@HiveType(typeId: 7) // Уникальный typeId
class ReturnItem extends HiveObject {
  @HiveField(0)
  final String returnType; // Тип возврата: "по чеку" или "ручной"

  @HiveField(1)
  final List<SharedItem> items; // Список возвращённых товаров

  @HiveField(2)
  final DateTime returnDate; // Дата возврата

  @HiveField(3)
  PaymentMethod paymentMethod; // Используем enum

  @HiveField(4)
  final String? comment; // Комментарий к возврату

  @HiveField(5) // Добавляем новое поле
  bool isDeleted;

@HiveField(6) // Добавляем поле createdAt
  final DateTime createdAt;

  ReturnItem({
    required this.returnType,
    required this.items,
    required this.returnDate,
    required this.paymentMethod,
    required this.createdAt, // Поле обязательно
    this.comment,
    this.isDeleted = false, // По умолчанию чек не удалён

  });

  // Геттеры для совместимости с ReceiptItem
  String get receiptNumber => returnDate.toIso8601String(); // Генерация из даты
  double get totalAmount =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  bool get hasReturn => true; // Возврат всегда произведён
}
