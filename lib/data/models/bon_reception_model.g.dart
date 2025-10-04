// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bon_reception_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BonReceptionAdapter extends TypeAdapter<BonReception> {
  @override
  final int typeId = 4;

  @override
  BonReception read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BonReception(
      id: fields[0] as String?,
      clientId: fields[1] as String,
      dateReception: fields[2] as DateTime,
      commandeNumber: fields[3] as String,
      articles: (fields[4] as List).cast<ArticleReception>(),
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      notes: fields[8] as String?,
      numeroBR: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BonReception obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.dateReception)
      ..writeByte(3)
      ..write(obj.commandeNumber)
      ..writeByte(4)
      ..write(obj.articles)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.numeroBR);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonReceptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
