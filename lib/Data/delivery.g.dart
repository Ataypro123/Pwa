// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryAdapter extends TypeAdapter<Delivery> {
  @override
  final int typeId = 0;

  @override
  Delivery read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Delivery(
      number: fields[0] as String,
      date: fields[1] as String,
      sender: fields[2] as String,
      receiver: fields[3] as String,
      responsible: fields[4] as String,
      quantity: fields[5] as int,
      totalAmount: fields[6] as double,
      items: (fields[7] as List).cast<DeliveryItem>(),
      isClosed: fields[8] as bool,
      barcode: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Delivery obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.sender)
      ..writeByte(3)
      ..write(obj.receiver)
      ..writeByte(4)
      ..write(obj.responsible)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.totalAmount)
      ..writeByte(7)
      ..write(obj.items)
      ..writeByte(8)
      ..write(obj.isClosed)
      ..writeByte(9)
      ..write(obj.barcode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeliveryItemAdapter extends TypeAdapter<DeliveryItem> {
  @override
  final int typeId = 1;

  @override
  DeliveryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryItem(
      barcode: fields[0] as String,
      name: fields[1] as String,
      quantity: fields[2] as int,
      price: fields[3] as double,
      price2: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.price2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
