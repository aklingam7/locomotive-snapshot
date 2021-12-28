import "package:flutter_test/flutter_test.dart";
import "package:locomotive/features/main_app/domain/entities/app_data.dart";
import "package:locomotive/features/main_app/domain/entities/coordinate.dart";
import "package:locomotive/features/main_app/domain/entities/date.dart";
import "package:locomotive/features/main_app/domain/entities/train.dart";

void main() {
  test("isValid should be false when duplicate train names exist", () {
    // arrange
    const train1 = Train(
      trainName: "trainx",
      color: TrainColor.deepOrange,
      caboosePosition: Coordinate(Date(33), TrainTrack.B),
      locomotivePosition: Coordinate(Date(333), TrainTrack.B),
    );
    const train2 = Train(
      trainName: "trainx",
      color: TrainColor.blue,
      caboosePosition: Coordinate(Date(32), TrainTrack.D),
      locomotivePosition: Coordinate(Date(323), TrainTrack.D),
    );
    final AppData appData = AppData(
      trains: const [train1, train2],
      freightCars: const [],
      source: AppDataSource.local,
    );
    // assert
    expect(appData.isValid, false);
  });
}
