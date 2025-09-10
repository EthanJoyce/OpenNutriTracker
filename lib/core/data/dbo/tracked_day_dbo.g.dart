// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_day_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackedDayDBOAdapter extends TypeAdapter<TrackedDayDBO> {
  @override
  final int typeId = 9;

  @override
  TrackedDayDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackedDayDBO(
      day: fields[0] as DateTime,
      calorieGoal: fields[1] as double,
      carbsGoal: fields[3] as double?,
      fatGoal: fields[5] as double?,
      proteinGoal: fields[7] as double?,
    )
      ..reserved0 = fields[2] as double
      ..reserved1 = fields[4] as double?
      ..reserved2 = fields[6] as double?
      ..reserved3 = fields[8] as double?;
  }

  @override
  void write(BinaryWriter writer, TrackedDayDBO obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.calorieGoal)
      ..writeByte(2)
      ..write(obj.reserved0)
      ..writeByte(3)
      ..write(obj.carbsGoal)
      ..writeByte(4)
      ..write(obj.reserved1)
      ..writeByte(5)
      ..write(obj.fatGoal)
      ..writeByte(6)
      ..write(obj.reserved2)
      ..writeByte(7)
      ..write(obj.proteinGoal)
      ..writeByte(8)
      ..write(obj.reserved3);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedDayDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackedDayDBO _$TrackedDayDBOFromJson(Map<String, dynamic> json) =>
    TrackedDayDBO(
      day: DateTime.parse(json['day'] as String),
      calorieGoal: (json['calorieGoal'] as num).toDouble(),
      carbsGoal: (json['carbsGoal'] as num?)?.toDouble(),
      fatGoal: (json['fatGoal'] as num?)?.toDouble(),
      proteinGoal: (json['proteinGoal'] as num?)?.toDouble(),
    )
      ..reserved0 = (json['reserved0'] as num).toDouble()
      ..reserved1 = (json['reserved1'] as num?)?.toDouble()
      ..reserved2 = (json['reserved2'] as num?)?.toDouble()
      ..reserved3 = (json['reserved3'] as num?)?.toDouble();

Map<String, dynamic> _$TrackedDayDBOToJson(TrackedDayDBO instance) =>
    <String, dynamic>{
      'day': instance.day.toIso8601String(),
      'calorieGoal': instance.calorieGoal,
      'reserved0': instance.reserved0,
      'carbsGoal': instance.carbsGoal,
      'reserved1': instance.reserved1,
      'fatGoal': instance.fatGoal,
      'reserved2': instance.reserved2,
      'proteinGoal': instance.proteinGoal,
      'reserved3': instance.reserved3,
    };
