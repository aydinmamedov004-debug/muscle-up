// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomExerciseAdapter extends TypeAdapter<CustomExercise> {
  @override
  final typeId = 6;

  @override
  CustomExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomExercise(
      name: fields[0] as String,
      muscleGroupName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomExercise obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.muscleGroupName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
