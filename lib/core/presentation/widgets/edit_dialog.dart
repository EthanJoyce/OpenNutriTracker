import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/utils/calc/unit_calc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class EditDialog extends StatefulWidget {
  final IntakeEntity intakeEntity;
  final bool usesImperialUnits;

  const EditDialog(
      {super.key, required this.intakeEntity, required this.usesImperialUnits});

  @override
  State<StatefulWidget> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late TextEditingController amountEditingController;

  @override
  void initState() {
    super.initState();
    double initialAmount = _convertValue(
        widget.intakeEntity.amount, widget.intakeEntity.meal.servingUnit);
    // Show 2 decimal places only if amount has a decimal component
    // I.e 2.374 => 2.37, while 2.00 => 2
    String initialAmountStr = (initialAmount.floor() == initialAmount)
          ? initialAmount.toStringAsFixed(0)
          : initialAmount.toStringAsFixed(2);
    amountEditingController =
        TextEditingController(text: initialAmountStr);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).editItemDialogTitle),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          controller: amountEditingController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: S.of(context).quantityLabel,
              suffixText:
                  _convertUnit(widget.intakeEntity.meal.servingUnit ?? '')),
        )
      ]),
      actions: [
        TextButton(
            onPressed: () {
              double newAmount = double.parse(amountEditingController.text);
              Navigator.of(context).pop(_convertBackToMetricValue(
                  newAmount, widget.intakeEntity.meal.servingUnit));
            },
            child: Text(S.of(context).dialogOKLabel)),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).dialogCancelLabel))
      ],
    );
  }

  double _convertValue(double value, String? unit) {
    switch (unit) {
      case 'g':
        return widget.usesImperialUnits ? UnitCalc.gToOz(value) : value;
      case 'ml':
        return widget.usesImperialUnits ? UnitCalc.mlToFlOz(value) : value;
      default:
        return value;
    }
  }

  double _convertBackToMetricValue(double value, String? unit) {
    switch (unit) {
      case 'g':
        return widget.usesImperialUnits ? UnitCalc.ozToG(value) : value;
      case 'ml':
        return widget.usesImperialUnits ? UnitCalc.flOzToMl(value) : value;
      default:
        return value;
    }
  }

  String _convertUnit(String unit) {
    switch (unit) {
      case 'g':
        return widget.usesImperialUnits ? 'oz' : 'g';
      case 'ml':
        return widget.usesImperialUnits ? 'fl.oz' : 'ml';
      default:
        return unit;
    }
  }
}
