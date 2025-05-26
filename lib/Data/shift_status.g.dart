// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftStatusAdapter extends TypeAdapter<ShiftStatus> {
  @override
  final int typeId = 8;

  @override
  ShiftStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShiftStatus(
      shiftId: fields[0] as String,
      isOpen: fields[1] as bool,
      openedAt: fields[2] as DateTime,
      closedAt: fields[3] as DateTime?,
      initialCash: fields[4] as double,
      totalCashAdded: fields[5] as double,
      totalCashWithdrawn: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ShiftStatus obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.shiftId)
      ..writeByte(1)
      ..write(obj.isOpen)
      ..writeByte(2)
      ..write(obj.openedAt)
      ..writeByte(3)
      ..write(obj.closedAt)
      ..writeByte(4)
      ..write(obj.initialCash)
      ..writeByte(5)
      ..write(obj.totalCashAdded)
      ..writeByte(6)
      ..write(obj.totalCashWithdrawn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
