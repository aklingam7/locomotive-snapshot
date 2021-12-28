import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";
import "package:locomotive/features/main_app/domain/entities/date.dart";

part "coordinate.g.dart";

@JsonSerializable()
class Coordinate extends Equatable {
  const Coordinate(this.date, this.track);

  final Date date;
  final TrainTrack track;

  @override
  List<Object> get props => [date, track];

  factory Coordinate.fromJson(Map<String, dynamic> json) =>
      _$CoordinateFromJson(json);
  Map<String, dynamic> toJson() => _$CoordinateToJson(this);
}

enum TrainTrack {
  A,
  B,
  C,
  D,
  E,
  F,
  G,
  H,
  I,
  J,
  K,
  L,
  M,
  N,
  O,
  P,
}
