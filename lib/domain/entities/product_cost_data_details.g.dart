// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_cost_data_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductCostDataDetailsAdapter
    extends TypeAdapter<ProductCostDataDetails> {
  @override
  final int typeId = 2;

  @override
  ProductCostDataDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductCostDataDetails(
      nmID: fields[0] as int,
      costType: fields[1] as String,
      name: fields[2] as String,
      amount: fields[3] as double,
      description: fields[4] as String?,
      mpType: fields[5] == null ? 'wb' : fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProductCostDataDetails obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nmID)
      ..writeByte(1)
      ..write(obj.costType)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.mpType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCostDataDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
