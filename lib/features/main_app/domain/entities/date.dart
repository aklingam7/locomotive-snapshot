import "package:equatable/equatable.dart";
import "package:json_annotation/json_annotation.dart";

part "date.g.dart";

final DateTime START_DT = DateTime.utc(2020);

@JsonSerializable()
class Date extends Equatable {
  const Date(this.day) : assert(day >= 0);

  factory Date.fromDateTime(DateTime dt) {
    return Date(dt.difference(START_DT).inDays);
  }

  factory Date.today() {
    return Date.fromDateTime(DateTime.now());
  }

  DateTime toDateTime() {
    return START_DT.add(Duration(days: day));
  }

  final int day;

  @override
  List<Object> get props => [day];

  Date operator +(int days) {
    return Date(day + days);
  }

  Date operator -(int days) {
    return Date(day - days);
  }

  factory Date.fromJson(Map<String, dynamic> json) => _$DateFromJson(json);
  Map<String, dynamic> toJson() => _$DateToJson(this);
}
