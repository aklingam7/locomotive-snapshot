import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";
import "package:locomotive/features/main_app/domain/entities/coordinate.dart";

part "freight_car.g.dart";

@JsonSerializable()
class FreightCar extends Equatable {
  const FreightCar(this.position, this.coalContent);

  final int coalContent;
  final Coordinate position;

  @override
  List<Object> get props => [position, coalContent];

  factory FreightCar.fromJson(Map<String, dynamic> json) =>
      _$FreightCarFromJson(json);

  Map<String, dynamic> toJson() => _$FreightCarToJson(this);
}
