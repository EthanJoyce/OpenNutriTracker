import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';

part 'recent_meal_event.dart';

part 'recent_meal_state.dart';

class RecentMealBloc extends Bloc<RecentMealEvent, RecentMealState> {
  final log = Logger('RecentMealBloc');

  final GetIntakeUsecase _getIntakeUsecase;
  final GetConfigUsecase _getConfigUsecase;

  RecentMealBloc(this._getIntakeUsecase, this._getConfigUsecase)
      : super(RecentMealInitial()) {
    on<LoadRecentMealEvent>((event, emit) async {
      emit(RecentMealLoadingState());
      try {
        final config = await _getConfigUsecase.getConfig();
        final searchString = event.searchString;
        final recentIntake = searchString.isEmpty ?
                                await _getIntakeUsecase.getRecentIntakesOfType(event.intakeType) :
                                await _getIntakeUsecase.getRecentIntake();

        if (searchString.isEmpty) {
          emit(RecentMealLoadedState(
              recentIntake: recentIntake,
              usesImperialUnits: config.usesImperialUnits));
        } else {
          emit(RecentMealLoadedState(
              recentIntake: recentIntake
                  .where(createFunctionMatchesSearchString(searchString))
                  .toList(),
              usesImperialUnits: config.usesImperialUnits));
        }
      } catch (error) {
        log.severe(error);
        emit(RecentMealFailedState());
      }
    });
  }

  bool Function(IntakeEntity) createFunctionMatchesSearchString(String searchString) {
    final searchTerms = searchString.toLowerCase().split(' ');
    return (intake) {
      bool matchesName = true;
      bool matchesBrand = true;
      for (String term in searchTerms) {
        matchesName  &= (intake.meal.name?.toLowerCase().contains(term) ?? false);
        matchesBrand &= (intake.meal.brands?.toLowerCase().contains(term) ?? false);
      }
      return matchesName || matchesBrand;
    };
  }
}
