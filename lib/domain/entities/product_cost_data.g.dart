// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_cost_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductCostDataAdapter extends TypeAdapter<ProductCostData> {
  @override
  final int typeId = 1;

  @override
  ProductCostData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductCostData(
      nmID: fields[0] as int,
      costPrice: fields[1] as double,
      delivery: fields[2] as double,
      packaging: fields[3] as double,
      paidAcceptance: fields[4] as double,
      warehouseName: fields[5] as String?,
      returnRate: fields[6] == null ? 10.0 : fields[6] as double,
      taxRate: fields[7] == null ? 7 : fields[7] as int,
      desiredMargin1: fields[8] == null ? 30 : fields[8] as double,
      desiredMargin2: fields[9] == null ? 20 : fields[9] as double,
      desiredMargin3: fields[10] == null ? 15 : fields[10] as double,
      calculatedPrice1: fields[11] == null ? 0 : fields[11] as double,
      calculatedPrice2: fields[12] == null ? 0 : fields[12] as double,
      calculatedPrice3: fields[13] == null ? 0 : fields[13] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ProductCostData obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.nmID)
      ..writeByte(1)
      ..write(obj.costPrice)
      ..writeByte(2)
      ..write(obj.delivery)
      ..writeByte(3)
      ..write(obj.packaging)
      ..writeByte(4)
      ..write(obj.paidAcceptance)
      ..writeByte(5)
      ..write(obj.warehouseName)
      ..writeByte(6)
      ..write(obj.returnRate)
      ..writeByte(7)
      ..write(obj.taxRate)
      ..writeByte(8)
      ..write(obj.desiredMargin1)
      ..writeByte(9)
      ..write(obj.desiredMargin2)
      ..writeByte(10)
      ..write(obj.desiredMargin3)
      ..writeByte(11)
      ..write(obj.calculatedPrice1)
      ..writeByte(12)
      ..write(obj.calculatedPrice2)
      ..writeByte(13)
      ..write(obj.calculatedPrice3);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCostDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
