import 'package:flutter/material.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class MealDetailNutrimentsTable extends StatelessWidget {
  final MealEntity product;
  final bool usesImperialUnits;
  final double? servingQuantity;
  final String? servingUnit;

  const MealDetailNutrimentsTable(
      {super.key,
      required this.product,
      required this.usesImperialUnits,
      this.servingQuantity,
      this.servingUnit});

  @override
  Widget build(BuildContext context) {
    final textStyleNormalMedium =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final textStyleBoldMedium = Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold) ??
        const TextStyle();
    final textStyleBoldTitle = Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold) ??
        const TextStyle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          defaultColumnWidth: MinColumnWidth(const FixedColumnWidth(250), FractionColumnWidth(1.0)),
          border: TableBorder.symmetric(
            inside: BorderSide.none,
            outside: BorderSide(width: 1, color: Colors.black),
          ),
          children: <TableRow>[
            _getNutrimentsTableRow(context, "", textStyleBoldTitle, S.of(context).nutritionInfoLabel, textStyleBoldTitle, MainAxisAlignment.center),
            _getDividerTableRow(context, 2.0),
            _getNutrimentsTableRow(
                context,
                S.of(context).perServingLabel,
                textStyleBoldMedium,
                "${servingQuantity!.toInt()} ${servingUnit ?? 'g/ml'}",
                textStyleBoldMedium,
                MainAxisAlignment.spaceBetween),
            _getDividerTableRow(context, 10.0),
            _getNutrimentsTableRow(
                context,
                S.of(context).caloriesLabel,
                textStyleBoldTitle,
                "${_adjustValueForServing(product.nutriments.energyKcal100?.toDouble() ?? 0).toInt()}",
                textStyleBoldTitle,
                MainAxisAlignment.spaceBetween),
            _getDividerTableRow(context, 5.0),
            _getNutrimentsTableRow(
                context,
                S.of(context).fatLabel,
                textStyleBoldMedium,
                "${_adjustValueForServing(product.nutriments.fat100 ?? 0).roundToPrecision(1)}g",
                textStyleNormalMedium,
                MainAxisAlignment.start),
            _getDividerTableRow(context, 1.0),
            _getNutrimentsTableRow(
                context,
                '   ${S.of(context).saturatedFatLabel}',
                textStyleNormalMedium,
                "${_adjustValueForServing(product.nutriments.saturatedFat100 ?? 0).roundToPrecision(1)}g",
                textStyleNormalMedium,
                MainAxisAlignment.start),
            _getDividerTableRow(context, 2.0),
            _getNutrimentsTableRow(
                context,
                S.of(context).carbohydrateLabel,
                textStyleBoldMedium,
                "${_adjustValueForServing(product.nutriments.carbohydrates100 ?? 0).roundToPrecision(1)}g",
                textStyleNormalMedium,
                MainAxisAlignment.start),
            _getDividerTableRow(context, 1.0),
            _getNutrimentsTableRow(
                context,
                '    ${S.of(context).fiberLabel}',
                textStyleNormalMedium,
                "${_adjustValueForServing(product.nutriments.fiber100 ?? 0).roundToPrecision(1)}g",
                textStyleNormalMedium,
                MainAxisAlignment.start),
            _getDividerTableRow(context, 1.0),
            _getNutrimentsTableRow(
                context,
                '    ${S.of(context).sugarLabel}',
                textStyleNormalMedium,
                "${_adjustValueForServing(product.nutriments.sugars100 ?? 0).roundToPrecision(1)}g",
                textStyleNormalMedium,
                MainAxisAlignment.start),
            _getDividerTableRow(context, 1.0),
            _getNutrimentsTableRow(
                context,
                S.of(context).proteinLabel,
                textStyleBoldMedium,
                "${_adjustValueForServing(product.nutriments.proteins100 ?? 0).roundToPrecision(1)}g",
                textStyleNormalMedium,
                MainAxisAlignment.start)
          ],
        )
      ],
    );
  }

  double _adjustValueForServing(double value) {
    if (servingQuantity == null) {
      return value;
    }
    // Calculate per serving value based on 100g reference
    return (value * servingQuantity!) / 100;
  }

  TableRow _getNutrimentsTableRow(
      BuildContext context, String label, TextStyle labelTextStyle, String quantityString, TextStyle quantityTextStyle, MainAxisAlignment alignment) {
    return TableRow(children: <Widget>[
      Container(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          mainAxisAlignment: alignment,
          children: [
            Text(label, style: labelTextStyle),
            Text(" "),
            Text(quantityString, style: quantityTextStyle),
          ]
        )
      ),
    ]);
  }

  TableRow _getDividerTableRow(
      BuildContext context, double thickness) {
    return TableRow(
      children: [
        Divider(height: thickness, thickness: thickness, indent: 8, endIndent: 8, color: Colors.black),
      ],
    );
  }
}
