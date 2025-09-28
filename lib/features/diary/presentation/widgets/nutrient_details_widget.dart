import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:opennutritracker/generated/l10n.dart';

class NutrientDetailsWidget extends StatelessWidget {
  final List<IntakeEntity> intakes;

  const NutrientDetailsWidget(
      {super.key,
      required this.intakes,});

  @override
  Widget build(BuildContext context) {
    final (kcals, fat, carbs, protein, satFat, fiber, sugars) = _getNutrientsSummed();

    final textStyleNormal =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final textStyleBold = Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold) ??
        const TextStyle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).nutrientDetailsLabel,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16.0),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5)),
          children: <TableRow>[
            _getNutrimentsTableRow(
                S.of(context).energyLabel,
                "${kcals.toInt()} ${S.of(context).kcalLabel}",
                textStyleNormal),
            _getNutrimentsTableRow(
                S.of(context).fatLabel,
                "${fat.roundToPrecision(2)} g",
                textStyleNormal),
            _getNutrimentsTableRow(
                '   ${S.of(context).saturatedFatLabel}',
                "${satFat.roundToPrecision(2)} g",
                textStyleNormal),
            _getNutrimentsTableRow(
                S.of(context).carbohydrateLabel,
                "${carbs.roundToPrecision(2)} g",
                textStyleNormal),
            _getNutrimentsTableRow(
                '    ${S.of(context).fiberLabel}',
                "${fiber.roundToPrecision(2)} g",
                textStyleNormal),
            _getNutrimentsTableRow(
                '    ${S.of(context).sugarLabel}',
                "${sugars.roundToPrecision(2)} g",
                textStyleNormal),
            _getNutrimentsTableRow(
                S.of(context).proteinLabel,
                "${protein.roundToPrecision(2)} g",
                textStyleNormal)
          ],
        )
      ],
    );
  }

  TableRow _getNutrimentsTableRow(
      String label, String quantityString, TextStyle textStyle) {
    return TableRow(children: <Widget>[
      Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(label, style: textStyle)),
      Container(
          padding: const EdgeInsets.only(right: 8.0),
          alignment: Alignment.centerRight,
          child: Text(quantityString, style: textStyle)),
    ]);
  }

  (double, double, double, double, double, double, double) _getNutrientsSummed() {
    double caloriesTracked = 0;
    double fatTracked = 0;
    double carbsTracked = 0;
    double proteinTracked = 0;
    double satFatTracked = 0;
    double fiberTracked = 0;
    double sugarsTracked = 0;

    for (var intakeItem in intakes) {
      caloriesTracked += intakeItem.totalKcal;
      fatTracked += intakeItem.totalFatsGram;
      carbsTracked += intakeItem.totalCarbsGram;
      proteinTracked += intakeItem.totalProteinsGram;
      satFatTracked += intakeItem.totalSatFatsGram;
      fiberTracked += intakeItem.totalFiberGram;
      sugarsTracked += intakeItem.totalSugarsGram;
    }
    return (caloriesTracked, carbsTracked, fatTracked, proteinTracked, satFatTracked, fiberTracked, sugarsTracked);
  }
}
