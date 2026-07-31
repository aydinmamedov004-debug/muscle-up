// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutHistoryAdapter extends TypeAdapter<WorkoutHistory> {
  @override
  final typeId = 0;

  @override
  WorkoutHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutHistory(
      workoutName: fields[0] as String,
      completedAt: fields[1] as DateTime,
      durationSeconds: (fields[2] as num).toInt(),
      exercises: (fields[3] as List).cast<ExerciseHistory>(),
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.workoutName)
      ..writeByte(1)
      ..write(obj.completedAt)
      ..writeByte(2)
      ..write(obj.durationSeconds)
      ..writeByte(3)
      ..write(obj.exercises)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
