// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bon_livraison_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BonLivraisonAdapter extends TypeAdapter<BonLivraison> {
  @override
  final int typeId = 7;

  @override
  BonLivraison read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BonLivraison(
      id: fields[0] as String?,
      blNumber: fields[1] as String,
      clientId: fields[2] as String,
      clientName: fields[3] as String,
      dateLivraison: fields[4] as DateTime,
      articles: (fields[5] as List).cast<ArticleLivraison>(),
      signature: fields[7] as String?,
      notes: fields[8] as String?,
      status: fields[11] as String,
      receptionId: fields[12] as String?,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BonLivraison obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.blNumber)
      ..writeByte(2)
      ..write(obj.clientId)
      ..writeByte(3)
      ..write(obj.clientName)
      ..writeByte(4)
      ..write(obj.dateLivraison)
      ..writeByte(5)
      ..write(obj.articles)
      ..writeByte(6)
      ..write(obj.montantTotal)
      ..writeByte(7)
      ..write(obj.signature)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.receptionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonLivraisonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
