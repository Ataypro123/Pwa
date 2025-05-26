// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SharedItemAdapter extends TypeAdapter<SharedItem> {
  @override
  final int typeId = 4;

  @override
  SharedItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedItem(
      barcode: fields[0] as String,
      name: fields[1] as String,
      quantity: fields[2] as int,
      price: fields[3] as double,
      price2: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SharedItem obj) {
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
      other is SharedItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
