import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';

part 'tracked_day_dbo.g.dart';

@HiveType(typeId: 9)
@JsonSerializable()
class TrackedDayDBO extends HiveObject {
  @HiveField(0)
  DateTime day;
  @HiveField(1)
  double calorieGoal;
  @HiveField(2)
  double reserved0 = 0;
  @HiveField(3)
  double? carbsGoal;
  @HiveField(4)
  double? reserved1 = 0;
  @HiveField(5)
  double? fatGoal;
  @HiveField(6)
  double? reserved2 = 0;
  @HiveField(7)
  double? proteinGoal;
  @HiveField(8)
  double? reserved3 = 0;

  TrackedDayDBO(
      {required this.day,
      required this.calorieGoal,
      this.carbsGoal,
      this.fatGoal,
      this.proteinGoal});

  factory TrackedDayDBO.fromTrackedDayEntity(TrackedDayEntity entity) {
    return TrackedDayDBO(
        day: entity.day,
        calorieGoal: entity.calorieGoal,
        carbsGoal: entity.carbsGoal,
        fatGoal: entity.fatGoal,
        proteinGoal: entity.proteinGoal);
  }

  factory TrackedDayDBO.fromJson(Map<String, dynamic> json) =>
      _$TrackedDayDBOFromJson(json);

  Map<String, dynamic> toJson() => _$TrackedDayDBOToJson(this);
}
