// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedProductAdapter extends TypeAdapter<SavedProduct> {
  @override
  final int typeId = 0;

  @override
  SavedProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedProduct(
      productId: fields[0] as String,
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      sellerId: fields[3] as int,
      sellerName: fields[4] as String,
      brandId: fields[5] as int,
      brandName: fields[6] as String,
      marketplaceType: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedProduct obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.sellerId)
      ..writeByte(4)
      ..write(obj.sellerName)
      ..writeByte(5)
      ..write(obj.brandId)
      ..writeByte(6)
      ..write(obj.brandName)
      ..writeByte(7)
      ..write(obj.marketplaceType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
