import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_const.dart';

part 'fdc_food_nutriment_dto.g.dart';

@JsonSerializable()
class FDCFoodNutrimentDTO {
  @JsonKey(name: FDCConst.fdcFieldNutrientId)
  final int? nutrientId;
  @JsonKey(name: FDCConst.fdcFieldNutrientAmount)
  final double? amount;

  FDCFoodNutrimentDTO({required this.nutrientId, required this.amount});

  factory FDCFoodNutrimentDTO.fromJson(Map<String, dynamic> json) =>
      _$FDCFoodNutrimentDTOFromJson(json);

  Map<String, dynamic> toJson() => _$FDCFoodNutrimentDTOToJson(this);
}
