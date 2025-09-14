import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:opennutritracker/core/presentation/widgets/copy_or_delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/copy_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/core/utils/custom_icons.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:opennutritracker/generated/l10n.dart';

import 'package:opennutritracker/features/home/presentation/widgets/dashboard_widget.dart';

class DayInfoWidget extends StatelessWidget {
  final bool showActivityTracker;
  final DateTime selectedDay;
  final TrackedDayEntity trackedDayEntity;
  final List<UserActivityEntity> userActivities;
  final List<IntakeEntity> breakfastIntake;
  final List<IntakeEntity> lunchIntake;
  final List<IntakeEntity> dinnerIntake;
  final List<IntakeEntity> snackIntake;

  final bool usesImperialUnits;
  final Function(BuildContext context, IntakeEntity intakeEntity, bool usesImperialUnits, TrackedDayEntity? trackedDayEntity)
      onUpdateIntake;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity)
      onDeleteIntake;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onDeleteActivity;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity,
      AddMealType? type) onCopyIntake;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onCopyActivity;

  const DayInfoWidget({
    super.key,
    required this.showActivityTracker,
    required this.selectedDay,
    required this.trackedDayEntity,
    required this.userActivities,
    required this.breakfastIntake,
    required this.lunchIntake,
    required this.dinnerIntake,
    required this.snackIntake,
    required this.usesImperialUnits,
    required this.onUpdateIntake,
    required this.onDeleteIntake,
    required this.onDeleteActivity,
    required this.onCopyIntake,
    required this.onCopyActivity,
  });

  @override
  Widget build(BuildContext context) {
    final (kcalTracked, carbsTracked, fatTracked, proteinTracked) = _getCaloriesAndMacrosTracked();
    final totalKcalActivities = userActivities.map((activity) => activity.burnedKcal).toList().sum;
    final kcalGoal = trackedDayEntity.calorieGoal;
    final carbsGoal = trackedDayEntity.carbsGoal ?? 0;
    final fatGoal = trackedDayEntity.fatGoal ?? 0;
    final proteinGoal = trackedDayEntity.proteinGoal ?? 0;
    final kcalRemaining = kcalGoal - kcalTracked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardWidget(
              totalKcalDaily: kcalGoal,
              totalKcalLeft: kcalRemaining,
              totalKcalSupplied: kcalTracked,
              totalKcalBurned: totalKcalActivities,
              totalCarbsIntake: carbsTracked,
              totalFatsIntake: fatTracked,
              totalProteinsIntake: proteinTracked,
              totalCarbsGoal: carbsGoal,
              totalFatsGoal: fatGoal,
              totalProteinsGoal: proteinGoal,
            ),
            const SizedBox(height: 8.0),
            showActivityTracker ?
              ActivityVerticalList(
                  day: selectedDay,
                  title: S.of(context).activityLabel,
                  userActivityList: userActivities,
                  onItemLongPressedCallback: onActivityItemLongPressed)
              : const SizedBox.shrink(),
            IntakeVerticalList(
              day: selectedDay,
              title: S.of(context).breakfastLabel,
              listIcon: Icons.bakery_dining_outlined,
              addMealType: AddMealType.breakfastType,
              intakeList: breakfastIntake,
              onItemTappedCallback: onUpdateIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(selectedDay, DateTime.now())
                      ? null
                      : onCopyIntake,
              usesImperialUnits: usesImperialUnits,
              trackedDayEntity: trackedDayEntity,
            ),
            IntakeVerticalList(
              day: selectedDay,
              title: S.of(context).lunchLabel,
              listIcon: Icons.lunch_dining_outlined,
              addMealType: AddMealType.lunchType,
              intakeList: lunchIntake,
              onItemTappedCallback: onUpdateIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              usesImperialUnits: usesImperialUnits,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(selectedDay, DateTime.now())
                      ? null
                      : onCopyIntake,
              trackedDayEntity: trackedDayEntity,
            ),
            IntakeVerticalList(
              day: selectedDay,
              title: S.of(context).dinnerLabel,
              listIcon: Icons.dinner_dining_outlined,
              addMealType: AddMealType.dinnerType,
              intakeList: dinnerIntake,
              onItemTappedCallback: onUpdateIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(selectedDay, DateTime.now())
                      ? null
                      : onCopyIntake,
              usesImperialUnits: usesImperialUnits,
            ),
            IntakeVerticalList(
              day: selectedDay,
              title: S.of(context).snackLabel,
              listIcon: CustomIcons.food_apple_outline,
              addMealType: AddMealType.snackType,
              intakeList: snackIntake,
              onItemTappedCallback: onUpdateIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              usesImperialUnits: usesImperialUnits,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(selectedDay, DateTime.now())
                      ? null
                      : onCopyIntake,
              trackedDayEntity: trackedDayEntity,
            ),
            const SizedBox(height: 16.0)
          ],
        )
      ],
    );
  }

  (double, double, double, double) _getCaloriesAndMacrosTracked() {
    double caloriesTracked = 0;
    double carbsTracked = 0;
    double fatTracked = 0;
    double proteinTracked = 0;

    final List<List<IntakeEntity>> intakeEntityLists = [breakfastIntake, lunchIntake, dinnerIntake, snackIntake];
    for (var intakeList in intakeEntityLists) {
      for (var intakeItem in intakeList) {
        caloriesTracked += intakeItem.totalKcal;
        carbsTracked += intakeItem.totalCarbsGram;
        fatTracked += intakeItem.totalFatsGram;
        proteinTracked += intakeItem.totalProteinsGram;
      }
    }
    return (caloriesTracked, carbsTracked, fatTracked, proteinTracked);
  }

  void showCopyOrDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final copyOrDelete = await showDialog<bool>(
        context: context, builder: (context) => const CopyOrDeleteDialog());
    if (context.mounted) {
      if (copyOrDelete != null && !copyOrDelete) {
        showDeleteIntakeDialog(context, intakeEntity);
      } else if (copyOrDelete != null && copyOrDelete) {
        showCopyDialog(context, intakeEntity);
      }
    }
  }

  void showCopyDialog(BuildContext context, IntakeEntity intakeEntity) async {
    const copyDialog = CopyDialog();
    final selectedMealType = await showDialog<AddMealType>(
        context: context, builder: (context) => copyDialog);
    if (selectedMealType != null) {
      onCopyIntake(intakeEntity, null, selectedMealType);
    }
  }

  void showDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final shouldDeleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());
    if (shouldDeleteIntake != null) {
      onDeleteIntake(intakeEntity, trackedDayEntity);
    }
  }

  void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    if (DateUtils.isSameDay(selectedDay, DateTime.now())) {
      showDeleteIntakeDialog(context, intakeEntity);
    } else {
      showCopyOrDeleteIntakeDialog(context, intakeEntity);
    }
  }

  void onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    final shouldDeleteActivity = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (shouldDeleteActivity != null) {
      onDeleteActivity(activityEntity, trackedDayEntity);
    }
  }
}
