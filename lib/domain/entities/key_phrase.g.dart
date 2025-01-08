// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_phrase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KeyPhraseAdapter extends TypeAdapter<KeyPhrase> {
  @override
  final int typeId = 1;

  @override
  KeyPhrase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KeyPhrase(
      phraseText: fields[0] as String,
      marketPlace: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KeyPhrase obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.phraseText)
      ..writeByte(1)
      ..write(obj.marketPlace);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyPhraseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
