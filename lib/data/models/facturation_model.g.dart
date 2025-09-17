// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facturation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FacturationAdapter extends TypeAdapter<Facturation> {
  @override
  final int typeId = 8;

  @override
  Facturation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Facturation(
      id: fields[0] as String?,
      factureNumber: fields[1] as String,
      clientFactureId: fields[2] as String,
      clientSourceId: fields[3] as String,
      dateFacture: fields[4] as DateTime,
      blReferences: (fields[5] as List).cast<String>(),
      totalAmount: fields[6] as double,
      status: fields[7] as String,
      datePaiement: fields[8] as DateTime?,
      commentaires: fields[9] as String?,
      dateCreation: fields[10] as DateTime?,
      dateModification: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Facturation obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.factureNumber)
      ..writeByte(2)
      ..write(obj.clientFactureId)
      ..writeByte(3)
      ..write(obj.clientSourceId)
      ..writeByte(4)
      ..write(obj.dateFacture)
      ..writeByte(5)
      ..write(obj.blReferences)
      ..writeByte(6)
      ..write(obj.totalAmount)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.datePaiement)
      ..writeByte(9)
      ..write(obj.commentaires)
      ..writeByte(10)
      ..write(obj.dateCreation)
      ..writeByte(11)
      ..write(obj.dateModification);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacturationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
