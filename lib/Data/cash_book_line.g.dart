// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_book_line.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CashBookLineAdapter extends TypeAdapter<CashBookLine> {
  @override
  final int typeId = 10;

  @override
  CashBookLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CashBookLine(
      lineId: fields[0] as String,
      openedAt: fields[1] as DateTime,
      closedAt: fields[2] as DateTime?,
      documents: (fields[3] as List).cast<CashDocument>(),
      cashBeforeOpening: fields[4] as double?,
      cashAfterClosing: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, CashBookLine obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.lineId)
      ..writeByte(1)
      ..write(obj.openedAt)
      ..writeByte(2)
      ..write(obj.closedAt)
      ..writeByte(3)
      ..write(obj.documents)
      ..writeByte(4)
      ..write(obj.cashBeforeOpening)
      ..writeByte(5)
      ..write(obj.cashAfterClosing);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashBookLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CashDocumentAdapter extends TypeAdapter<CashDocument> {
  @override
  final int typeId = 11;

  @override
  CashDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CashDocument(
      documentId: fields[0] as String,
      type: fields[1] as CashDocumentType,
      createdAt: fields[2] as DateTime,
      amount: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CashDocument obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.documentId)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CashDocumentTypeAdapter extends TypeAdapter<CashDocumentType> {
  @override
  final int typeId = 10;

  @override
  CashDocumentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CashDocumentType.deposit;
      case 1:
        return CashDocumentType.withdrawal;
      default:
        return CashDocumentType.deposit;
    }
  }

  @override
  void write(BinaryWriter writer, CashDocumentType obj) {
    switch (obj) {
      case CashDocumentType.deposit:
        writer.writeByte(0);
        break;
      case CashDocumentType.withdrawal:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashDocumentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
