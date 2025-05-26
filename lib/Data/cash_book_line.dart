import 'package:hive/hive.dart';
part 'cash_book_line.g.dart';

@HiveType(typeId: 10)
class CashBookLine extends HiveObject {
  @HiveField(0)
  final String lineId; // Уникальный ID строки

  @HiveField(1)
  final DateTime openedAt; // Дата открытия смены

  @HiveField(2)
  DateTime? closedAt; // Дата закрытия смены

  @HiveField(3)
  final List<CashDocument> documents; // Список документов

  @HiveField(4)
  double? cashBeforeOpening;

  @HiveField(5)
  double? cashAfterClosing;

  CashBookLine({
    required this.lineId,
    required this.openedAt,
    this.closedAt,
    this.documents = const [],
    this.cashBeforeOpening,
    this.cashAfterClosing,
  });

  // Добавление документа
  void addDocument(CashDocument document) {
    documents.add(document);
    save();
  }

  // Итоговая сумма смены
  double get totalCashAdded => documents
      .where((doc) => doc.type == CashDocumentType.deposit)
      .fold(0.0, (sum, doc) => sum + doc.amount);

  double get totalCashWithdrawn => documents
      .where((doc) => doc.type == CashDocumentType.withdrawal)
      .fold(0.0, (sum, doc) => sum + doc.amount);
}
@HiveType(typeId: 10)
enum CashDocumentType {
  @HiveField(0)
  deposit,
  @HiveField(1)
  withdrawal,
}

@HiveType(typeId: 11)
class CashDocument extends HiveObject {
  @HiveField(0)
  final String documentId;

  @HiveField(1)
  final CashDocumentType type;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final double amount;

  CashDocument({
    required this.documentId,
    required this.type,
    required this.createdAt,
    required this.amount,
  });
}
