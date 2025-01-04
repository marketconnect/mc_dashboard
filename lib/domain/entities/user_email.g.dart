// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_email.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserEmailAdapter extends TypeAdapter<UserEmail> {
  @override
  final int typeId = 2;

  @override
  UserEmail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserEmail(
      email: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserEmail obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEmailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
