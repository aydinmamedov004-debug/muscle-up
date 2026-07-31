// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_workout_program.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoredWorkoutProgramAdapter extends TypeAdapter<StoredWorkoutProgram> {
  @override
  final typeId = 5;

  @override
  StoredWorkoutProgram read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoredWorkoutProgram(
      name: fields[0] as String,
      exercises: (fields[1] as List).cast<StoredExerciseTemplate>(),
    );
  }

  @override
  void write(BinaryWriter writer, StoredWorkoutProgram obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.exercises);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredWorkoutProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
