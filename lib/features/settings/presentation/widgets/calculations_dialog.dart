import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/utils/calc/macro_calc.dart';
import 'package:opennutritracker/core/utils/calc/calorie_goal_calc.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class CalculationsDialog extends StatefulWidget {
  final SettingsBloc settingsBloc;
  final ProfileBloc profileBloc;
  final DiaryBloc diaryBloc;
  final CalendarDayBloc calendarDayBloc;
  final UserEntity user;

  const CalculationsDialog({
    super.key,
    required this.settingsBloc,
    required this.profileBloc,
    required this.diaryBloc,
    required this.calendarDayBloc,
    required this.user,
  });

  @override
  State<CalculationsDialog> createState() => _CalculationsDialogState();
}

enum MacroSelectionType {
  none,
  carbs,
  protein,
  fat,
}

class _CalculationsDialogState extends State<CalculationsDialog> {
  late TextEditingController _kcalGoalEditingController;
  double _kcalAdjustment = 0;

  static const double _defaultCarbsPctSelection = 0.6;
  static const double _defaultFatPctSelection = 0.25;
  static const double _defaultProteinPctSelection = 0.15;

  static const int _minimumMacroPercentage = 0;

  // Macros percentages
  double _carbsPctSelection = _defaultCarbsPctSelection * 100;
  double _proteinPctSelection = _defaultProteinPctSelection * 100;
  double _fatPctSelection = _defaultFatPctSelection * 100;
  
  MacroSelectionType _lastChangedMacro = MacroSelectionType.none;
  MacroSelectionType _currentChangingMacro = MacroSelectionType.none;

  @override
  void initState() {
    super.initState();
    _kcalGoalEditingController = TextEditingController();
    _initializeKcalAdjustment();
  }

  void _initializeKcalAdjustment() async {
    final kcalAdjustment = await widget.settingsBloc.getKcalAdjustment() *
        1.0; // Convert to double
    final userCarbsPct = await widget.settingsBloc.getUserCarbGoalPct();
    final userProteinPct = await widget.settingsBloc.getUserProteinGoalPct();
    final userFatPct = await widget.settingsBloc.getUserFatGoalPct();

    setState(() {
      _kcalAdjustment = kcalAdjustment;
      _carbsPctSelection = (userCarbsPct ?? _defaultCarbsPctSelection) * 100;
      _proteinPctSelection =
          (userProteinPct ?? _defaultProteinPctSelection) * 100;
      _fatPctSelection = (userFatPct ?? _defaultFatPctSelection) * 100;
    });
  }

  @override
  void dispose() {
    _kcalGoalEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kcalDefaultValue = CalorieGoalCalc.getTotalKcalGoal(widget.user,
        /*totalKcalActivities=*/0, kcalUserAdjustment: 0);
    final kcalAbsValue = CalorieGoalCalc.getTotalKcalGoal(widget.user,
        /*totalKcalActivities=*/0, kcalUserAdjustment: _kcalAdjustment);
    final carbsAbsValue = MacroCalc.getTotalCarbsGoal(kcalAbsValue,
        userCarbsGoal: (_carbsPctSelection / 100.0));
    final proteinAbsValue = MacroCalc.getTotalProteinsGoal(kcalAbsValue,
        userProteinsGoal: (_proteinPctSelection / 100.0));
    final fatAbsValue = MacroCalc.getTotalFatsGoal(kcalAbsValue,
        userFatsGoal: (_fatPctSelection / 100.0));
    _kcalGoalEditingController.text = kcalAbsValue.roundToDouble().toInt().toString();
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              S.of(context).settingsCalculationsLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8), // Add spacing between text and button
          TextButton(
            child: Text(S.of(context).buttonResetLabel),
            onPressed: () {
              setState(() {
                _kcalAdjustment = 0;
                // Reset macros to default values
                _carbsPctSelection = _defaultCarbsPctSelection * 100;
                _proteinPctSelection = _defaultProteinPctSelection * 100;
                _fatPctSelection = _defaultFatPctSelection * 100;
              });
            },
          ),
        ],
      ),
      content: Wrap(
        children: [
          TextFormField(
            controller: _kcalGoalEditingController
              ..addListener(() {
                setState(() {
                  final newKcalGoal = double.tryParse(_kcalGoalEditingController.text) ?? 0;
                  _kcalAdjustment = newKcalGoal - kcalDefaultValue;
                });
              }),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
            decoration: InputDecoration(
                suffixText: S.of(context).kcalLabel
            ),
          ),
          const SizedBox(height: 64),
          _buildMacroSlider(
            context,
            S.of(context).carbsLabel,
            _carbsPctSelection,
            carbsAbsValue,
            Colors.orange,
            (value) {
              setState(() {
                // Implement a "latch" here - _currentChangingMacro is the one
                // currently being changed, and _lastChangedMacro is whatever
                // macro was previously being changed before this one
                if (_currentChangingMacro != MacroSelectionType.carbs) {
                  _lastChangedMacro = _currentChangingMacro;
                }
                _currentChangingMacro = MacroSelectionType.carbs;

                double delta = value - _carbsPctSelection;
                _carbsPctSelection = value;

                // Always preserve the last changed macro
                switch (_lastChangedMacro) {
                case MacroSelectionType.none:
                case MacroSelectionType.carbs:
                  _proteinPctSelection -= delta / 2.0;
                  _fatPctSelection -= delta / 2.0;
                  break;
                case MacroSelectionType.fat:
                  _proteinPctSelection -= delta;
                  break;
                case MacroSelectionType.protein:
                  _fatPctSelection -= delta;
                  break;
                }

                // Ensure no value goes below the minimum value
                if (_proteinPctSelection < _minimumMacroPercentage) {
                  double overflow = _minimumMacroPercentage - _proteinPctSelection;
                  _proteinPctSelection = _minimumMacroPercentage.toDouble();
                  _fatPctSelection -= overflow;
                }
                if (_fatPctSelection < _minimumMacroPercentage) {
                  double overflow = _minimumMacroPercentage - _fatPctSelection;
                  _fatPctSelection = _minimumMacroPercentage.toDouble();
                  _proteinPctSelection -= overflow;
                }
              });
            },
          ),
          _buildMacroSlider(
            context,
            S.of(context).proteinLabel,
            _proteinPctSelection,
            proteinAbsValue,
            Colors.blue,
            (value) {
              setState(() {
                // Implement a "latch" here - _currentChangingMacro is the one
                // currently being changed, and _lastChangedMacro is whatever
                // macro was previously being changed before this one
                if (_currentChangingMacro != MacroSelectionType.protein) {
                  _lastChangedMacro = _currentChangingMacro;
                }
                _currentChangingMacro = MacroSelectionType.protein;

                double delta = value - _proteinPctSelection;
                _proteinPctSelection = value;

                // Always preserve the last changed macro
                switch (_lastChangedMacro) {
                case MacroSelectionType.none:
                case MacroSelectionType.protein:
                  _carbsPctSelection -= delta / 2.0;
                  _fatPctSelection -= delta / 2.0;
                  break;
                case MacroSelectionType.fat:
                  _carbsPctSelection -= delta;
                  break;
                case MacroSelectionType.carbs:
                  _fatPctSelection -= delta;
                  break;
                }

                if (_carbsPctSelection < _minimumMacroPercentage) {
                  double overflow = _minimumMacroPercentage - _carbsPctSelection;
                  _carbsPctSelection = _minimumMacroPercentage.toDouble();
                  _fatPctSelection -= overflow;
                }
                if (_fatPctSelection < _minimumMacroPercentage) {
                  double overflow = _minimumMacroPercentage - _fatPctSelection;
                  _fatPctSelection = _minimumMacroPercentage.toDouble();
                  _carbsPctSelection -= overflow;
                }
              });
            },
          ),
          _buildMacroSlider(
            context,
            S.of(context).fatLabel,
            _fatPctSelection,
            fatAbsValue,
            Colors.green,
            (value) {
              setState(() {
                // Implement a "latch" here - _currentChangingMacro is the one
                // currently being changed, and _lastChangedMacro is whatever
                // macro was previously being changed before this one
                if (_currentChangingMacro != MacroSelectionType.fat) {
                  _lastChangedMacro = _currentChangingMacro;
                }
                _currentChangingMacro = MacroSelectionType.fat;

                double delta = value - _fatPctSelection;
                _fatPctSelection = value;

                // Always preserve the last changed macro
                switch (_lastChangedMacro) {
                case MacroSelectionType.none:
                case MacroSelectionType.fat:
                  _carbsPctSelection -= delta / 2.0;
                  _proteinPctSelection -= delta / 2.0;
                  break;
                case MacroSelectionType.protein:
                  _carbsPctSelection -= delta;
                  break;
                case MacroSelectionType.carbs:
                  _proteinPctSelection -= delta;
                  break;
                }

                if (_carbsPctSelection < _minimumMacroPercentage) {
                  double overflow = _minimumMacroPercentage - _carbsPctSelection;
                  _carbsPctSelection = _minimumMacroPercentage.toDouble();
                  _proteinPctSelection -= overflow;
                }
                if (_proteinPctSelection < _minimumMacroPercentage) {
                  double overflow = _minimumMacroPercentage - _proteinPctSelection;
                  _proteinPctSelection = _minimumMacroPercentage.toDouble();
                  _carbsPctSelection -= overflow;
                }
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).dialogCancelLabel)),
        TextButton(
            onPressed: () {
              _saveCalculationSettings();
            },
            child: Text(S.of(context).dialogOKLabel))
      ],
    );
  }

  Widget _buildMacroSlider(
    BuildContext context,
    String label,
    double pctValue,
    double absValue,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$label - ${absValue.toInt()} ${S.of(context).gramUnit}"),
            Text('${pctValue.round()}%'),
          ],
        ),
        SizedBox(
          width: 280,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: _minimumMacroPercentage.toDouble(),
              max: 100,
              value: pctValue,
              divisions: 100 - _minimumMacroPercentage,
              onChanged: (value) {
                final newValue = value.round().toDouble();
                if (newValue + (2*_minimumMacroPercentage) <= 100) {
                  onChanged(newValue);
                  _normalizeMacros();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void _normalizeMacros() {
    setState(() {
      // First, ensure all values are rounded
      _carbsPctSelection = _carbsPctSelection.roundToDouble();
      _proteinPctSelection = _proteinPctSelection.roundToDouble();
      _fatPctSelection = _fatPctSelection.roundToDouble();

      // Calculate total
      double total =
          _carbsPctSelection + _proteinPctSelection + _fatPctSelection;

      // If total isn't 100, adjust values proportionally
      if (total != 100) {
        // Calculate adjustment factor
        double factor = 100 / total;

        // Adjust the first two values
        _carbsPctSelection = (_carbsPctSelection * factor).roundToDouble();
        _proteinPctSelection = (_proteinPctSelection * factor).roundToDouble();

        // Set the last value to make total exactly 100
        _fatPctSelection = 100 - _carbsPctSelection - _proteinPctSelection;

        // Ensure minimum values
        if (_fatPctSelection < _minimumMacroPercentage) {
          _fatPctSelection = _minimumMacroPercentage.toDouble();
          // Distribute remaining proportionally between carbs and protein
          double remaining = 100 - _minimumMacroPercentage.toDouble();
          double ratio =
              _carbsPctSelection / (_carbsPctSelection + _proteinPctSelection);
          _carbsPctSelection = (remaining * ratio).roundToDouble();
          _proteinPctSelection = remaining - _carbsPctSelection;
        }
      }

      // Verify final values
      assert(
          _carbsPctSelection + _proteinPctSelection + _fatPctSelection == 100,
          'Macros must total 100%');
    });
  }

  void _saveCalculationSettings() {
    // Save the calorie offset as full number
    widget.settingsBloc
        .setKcalAdjustment(_kcalAdjustment);
    widget.settingsBloc.setMacroGoals(
        _carbsPctSelection, _proteinPctSelection, _fatPctSelection);

    widget.settingsBloc.add(LoadSettingsEvent());
    // Update other blocs that need the new calorie value
    widget.profileBloc.add(LoadProfileEvent());

    // Update tracked day entity
    widget.settingsBloc.updateTrackedDay(DateTime.now());
    widget.diaryBloc.add(LoadDiaryYearEvent());
    widget.calendarDayBloc.add(RefreshCalendarDayEvent());

    Navigator.of(context).pop();
  }
}
