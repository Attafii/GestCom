// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_reception_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleReceptionAdapter extends TypeAdapter<ArticleReception> {
  @override
  final int typeId = 3;

  @override
  ArticleReception read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticleReception(
      articleReference: fields[0] as String,
      quantity: fields[1] as int,
      unitPrice: fields[2] as double,
      articleDesignation: fields[3] as String,
      treatmentId: fields[4] as String?,
      treatmentName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleReception obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.articleReference)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unitPrice)
      ..writeByte(3)
      ..write(obj.articleDesignation)
      ..writeByte(4)
      ..write(obj.treatmentId)
      ..writeByte(5)
      ..write(obj.treatmentName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleReceptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
