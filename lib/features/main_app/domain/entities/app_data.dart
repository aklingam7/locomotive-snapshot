import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";
import "package:locomotive/features/main_app/domain/entities/coordinate.dart";
import "package:locomotive/features/main_app/domain/entities/date.dart";
import "package:locomotive/features/main_app/domain/entities/freight_car.dart";
import "package:locomotive/features/main_app/domain/entities/train.dart";

part "app_data.g.dart";

@JsonSerializable()
class AppData extends Equatable {
  AppData({
    required this.trains,
    required this.freightCars,
    required this.source,
    DateTime? lastChanged,
  }) {
    this.lastChanged = lastChanged ?? DateTime.now();
    if (trains.map((e) => e.trainName).toSet().length != trains.length) {
      _isValid.add(false);
    }
    for (final train in trains) {
      if (!train.isValid) _isValid.add(false);
      final track = train.locomotivePosition.track;
      final List<Coordinate> trainCoordinates = [
        for (int i = train.caboosePosition.date.day;
            i <= train.locomotivePosition.date.day;
            i++)
          Coordinate(Date(i), track)
      ];
      for (final c in trainCoordinates) {
        if (trainsMap[c] == null) {
          trainsMap[c] = train;
        } else {
          _isValid.add(false);
        }
      }
    }
    for (final car in freightCars) {
      if (carsMap[car.position] == null) {
        carsMap[car.position] = car;
      } else {
        _isValid.add(false);
      }
    }
    if (_isValid.isEmpty) _isValid.add(true);
  }

  final List<Train> trains;
  final List<FreightCar> freightCars;
  final AppDataSource source;
  late final DateTime lastChanged;

  final _isValid = <bool>[];

  final Map<Coordinate, Train> trainsMap = {};
  final Map<Coordinate, FreightCar> carsMap = {};

  bool get isValid => _isValid[0];
  int get numErrors => _isValid.length;

  @override
  List<Object> get props => [trains, freightCars, source, lastChanged];

  factory AppData.fromJson(Map<String, dynamic> json) =>
      _$AppDataFromJson(json);

  Map<String, dynamic> toJson() => _$AppDataToJson(this);
}

enum AppDataSource {
  local,
  server,
  initial,
}
