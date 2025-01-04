// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mailing_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DynamicMailingSettingsAdapter
    extends TypeAdapter<DynamicMailingSettings> {
  @override
  final int typeId = 3;

  @override
  DynamicMailingSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DynamicMailingSettings(
      settings: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DynamicMailingSettings obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DynamicMailingSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
