// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_exercise_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoredExerciseTemplateAdapter
    extends TypeAdapter<StoredExerciseTemplate> {
  @override
  final typeId = 4;

  @override
  StoredExerciseTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoredExerciseTemplate(
      name: fields[0] as String,
      targetSets: fields[1] == null ? 3 : (fields[1] as num).toInt(),
      minReps: fields[2] == null ? 8 : (fields[2] as num).toInt(),
      maxReps: fields[3] == null ? 12 : (fields[3] as num).toInt(),
      restSeconds: fields[4] == null ? 90 : (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, StoredExerciseTemplate obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.targetSets)
      ..writeByte(2)
      ..write(obj.minReps)
      ..writeByte(3)
      ..write(obj.maxReps)
      ..writeByte(4)
      ..write(obj.restSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredExerciseTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
