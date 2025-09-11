import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:opennutritracker/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';

class MealItemCard extends StatelessWidget {
  final DateTime day;
  final AddMealType addMealType;
  final bool usesImperialUnits;

  // Either or can be used to populate the widget
  final IntakeEntity? intakeEntity;
  final MealEntity? mealEntity;

  const MealItemCard(
      {super.key,
      required this.day,
      required this.addMealType,
      required this.usesImperialUnits,
      required this.intakeEntity,
      required this.mealEntity});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        child: SizedBox(
          height: 100,
          child: Center(
              child: ListTile(
            leading: _getMealEntity()?.thumbnailImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      cacheManager: locator<CacheManager>(),
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      imageUrl: _getMealEntity()!.thumbnailImageUrl ?? "",
                    ))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                        width: 60,
                        height: 60,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: const Icon(Icons.restaurant_outlined)),
                  ),
            title: AutoSizeText.rich(
                TextSpan(
                    text: _getMealEntity()?.name ?? "?",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                    children: [
                      TextSpan(
                          text: ' ${_getMealEntity()?.brands ?? ""}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.8))),
                    ]),
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            subtitle: ((intakeEntity != null) || (mealEntity?.servingQuantity != null))
                ? MealValueUnitText(
                    value: intakeEntity != null ?
                                intakeEntity!.amount :
                                mealEntity?.servingQuantity ?? 0,
                    meal: _getMealEntity()!,
                    usesImperialUnits: usesImperialUnits)
                : const SizedBox(),
            trailing: IconButton(
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              icon: const Icon(Icons.add_outlined),
              onPressed: () => _onItemPressed(context),
            ),
          )),
        ),
        onTap: () => _onItemPressed(context),
      ),
    );
  }

  MealEntity? _getMealEntity() {
    if (intakeEntity != null) {
      return intakeEntity!.meal;
    } else {
      return mealEntity;
    }
  }

  void _onItemPressed(BuildContext context) {
    String initialQuantity = intakeEntity != null ?
                                // Show 2 decimal places only if amount has a decimal component
                                // I.e 2.374 => 2.37, while 2.00 => 2
                                ((intakeEntity!.amount.floor() == intakeEntity!.amount)
                                    ? intakeEntity!.amount.toStringAsFixed(0)
                                    : intakeEntity!.amount.toStringAsFixed(2))
                                : "";
    String initialUnit = intakeEntity != null ? intakeEntity!.unit : "";
    Navigator.of(context).pushNamed(NavigationOptions.mealDetailRoute,
        arguments: MealDetailScreenArguments(
            _getMealEntity()!, addMealType.getIntakeType(), day, usesImperialUnits, initialQuantity, initialUnit));
  }
}
