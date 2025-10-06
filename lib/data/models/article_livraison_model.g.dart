// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_livraison_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleLivraisonAdapter extends TypeAdapter<ArticleLivraison> {
  @override
  final int typeId = 6;

  @override
  ArticleLivraison read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticleLivraison(
      articleReference: fields[0] as String,
      articleDesignation: fields[1] as String,
      quantityLivree: fields[2] as int,
      treatmentId: fields[3] as String,
      treatmentName: fields[4] as String,
      prixUnitaire: fields[5] as double,
      receptionId: fields[7] as String?,
      commentaire: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleLivraison obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.articleReference)
      ..writeByte(1)
      ..write(obj.articleDesignation)
      ..writeByte(2)
      ..write(obj.quantityLivree)
      ..writeByte(3)
      ..write(obj.treatmentId)
      ..writeByte(4)
      ..write(obj.treatmentName)
      ..writeByte(5)
      ..write(obj.prixUnitaire)
      ..writeByte(6)
      ..write(obj.montantTotal)
      ..writeByte(7)
      ..write(obj.receptionId)
      ..writeByte(8)
      ..write(obj.commentaire);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleLivraisonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
