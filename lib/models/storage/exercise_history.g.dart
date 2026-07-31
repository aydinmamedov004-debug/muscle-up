// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseHistoryAdapter extends TypeAdapter<ExerciseHistory> {
  @override
  final typeId = 2;

  @override
  ExerciseHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseHistory(
      name: fields[0] as String,
      sets: (fields[1] as List).cast<SetHistory>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseHistory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
