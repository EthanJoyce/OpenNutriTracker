part of 'recent_meal_bloc.dart';

abstract class RecentMealState extends Equatable {
  const RecentMealState();
}

class RecentMealInitial extends RecentMealState {
  @override
  List<Object> get props => [];
}

class RecentMealLoadingState extends RecentMealState {
  @override
  List<Object?> get props => [];
}

class RecentMealLoadedState extends RecentMealState {
  final List<IntakeEntity> recentIntake;
  final bool usesImperialUnits;

  const RecentMealLoadedState(
      {required this.recentIntake, this.usesImperialUnits = false});

  @override
  List<Object?> get props => [recentIntake, usesImperialUnits];
}

class RecentMealFailedState extends RecentMealState {
  @override
  List<Object?> get props => [];
}
