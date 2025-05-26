// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptItemAdapter extends TypeAdapter<ReceiptItem> {
  @override
  final int typeId = 5;

  @override
  ReceiptItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceiptItem(
      receiptNumber: fields[0] as String,
      items: (fields[1] as List).cast<SharedItem>(),
      totalAmount: fields[2] as double,
      paymentMethod: fields[3] as PaymentMethod,
      createdAt: fields[4] as DateTime,
      comment: fields[5] as String?,
      isDeleted: fields[6] as bool,
      hasReturn: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.receiptNumber)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.paymentMethod)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.isDeleted)
      ..writeByte(7)
      ..write(obj.hasReturn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DebtorItemAdapter extends TypeAdapter<DebtorItem> {
  @override
  final int typeId = 6;

  @override
  DebtorItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtorItem(
      receiptNumber: fields[0] as String,
      items: (fields[1] as List).cast<SharedItem>(),
      totalAmount: fields[2] as double,
      debtorName: fields[3] as String,
      debtorPhone: fields[4] as String,
      paymentMethod: fields[5] as String,
      createdAt: fields[6] as DateTime,
      returnDate: fields[7] as DateTime,
      comment: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DebtorItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.receiptNumber)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.debtorName)
      ..writeByte(4)
      ..write(obj.debtorPhone)
      ..writeByte(5)
      ..write(obj.paymentMethod)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.returnDate)
      ..writeByte(8)
      ..write(obj.comment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtorItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReturnItemAdapter extends TypeAdapter<ReturnItem> {
  @override
  final int typeId = 7;

  @override
  ReturnItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReturnItem(
      returnType: fields[0] as String,
      items: (fields[1] as List).cast<SharedItem>(),
      returnDate: fields[2] as DateTime,
      paymentMethod: fields[3] as PaymentMethod,
      createdAt: fields[6] as DateTime,
      comment: fields[4] as String?,
      isDeleted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReturnItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.returnType)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.returnDate)
      ..writeByte(3)
      ..write(obj.paymentMethod)
      ..writeByte(4)
      ..write(obj.comment)
      ..writeByte(5)
      ..write(obj.isDeleted)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReturnItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
