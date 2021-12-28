import "package:equatable/equatable.dart";
import "package:flutter/material.dart";
import "package:json_annotation/json_annotation.dart";
import "package:locomotive/features/main_app/domain/entities/coordinate.dart";

part "train.g.dart";

@JsonSerializable()
class Train extends Equatable {
  const Train({
    required this.trainName,
    required this.color,
    required this.caboosePosition,
    required this.locomotivePosition,
  });

  final String trainName;
  final TrainColor color;
  final Coordinate caboosePosition;
  final Coordinate locomotivePosition;

  bool get isValid =>
      caboosePosition.track == locomotivePosition.track &&
      caboosePosition.date.day < locomotivePosition.date.day;

  @override
  List<Object> get props => [caboosePosition, locomotivePosition];

  factory Train.fromJson(Map<String, dynamic> json) => _$TrainFromJson(json);

  Map<String, dynamic> toJson() => _$TrainToJson(this);
}

enum TrainColor {
  pink,
  red,
  deepOrange,
  orange,
  amber,
  yellow,
  lime,
  lightGreen,
  green,
  teal,
  cyan,
  lightBlue,
  blue,
  purple,
  deepPurple,
}

extension ToColor on TrainColor {
  ColorSwatch getColor() {
    switch (this) {
      case TrainColor.pink:
        return Colors.pink;
      case TrainColor.red:
        return Colors.red;
      case TrainColor.deepOrange:
        return Colors.deepOrange;
      case TrainColor.orange:
        return Colors.orange;
      case TrainColor.amber:
        return Colors.amber;
      case TrainColor.yellow:
        return Colors.yellow;
      case TrainColor.lime:
        return Colors.lime;
      case TrainColor.lightGreen:
        return Colors.lightGreen;
      case TrainColor.green:
        return Colors.green;
      case TrainColor.teal:
        return Colors.teal;
      case TrainColor.cyan:
        return Colors.cyan;
      case TrainColor.lightBlue:
        return Colors.lightBlue;
      case TrainColor.blue:
        return Colors.blue;
      case TrainColor.purple:
        return Colors.purple;
      case TrainColor.deepPurple:
        return Colors.deepPurple;
      default:
        return Colors.green;
    }
  }
}

extension ToTrainColor on ColorSwatch {
  TrainColor getTrainColor() {
    if (this == Colors.pink) {
      return TrainColor.pink;
    }
    if (this == Colors.red) {
      return TrainColor.red;
    }
    if (this == Colors.deepOrange) {
      return TrainColor.deepOrange;
    }
    if (this == Colors.orange) {
      return TrainColor.orange;
    }
    if (this == Colors.amber) {
      return TrainColor.amber;
    }
    if (this == Colors.yellow) {
      return TrainColor.yellow;
    }
    if (this == Colors.lime) {
      return TrainColor.lime;
    }
    if (this == Colors.lightGreen) {
      return TrainColor.lightGreen;
    }
    if (this == Colors.green) {
      return TrainColor.green;
    }
    if (this == Colors.teal) {
      return TrainColor.teal;
    }
    if (this == Colors.cyan) {
      return TrainColor.cyan;
    }
    if (this == Colors.lightBlue) {
      return TrainColor.lightBlue;
    }
    if (this == Colors.blue) {
      return TrainColor.blue;
    }
    if (this == Colors.purple) {
      return TrainColor.purple;
    }
    if (this == Colors.deepPurple) {
      return TrainColor.deepPurple;
    } else {
      return TrainColor.green;
    }
  }
}
