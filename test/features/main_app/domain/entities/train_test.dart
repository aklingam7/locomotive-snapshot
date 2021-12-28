import "package:flutter_test/flutter_test.dart";
import "package:locomotive/features/main_app/domain/entities/coordinate.dart";
import "package:locomotive/features/main_app/domain/entities/date.dart";
import "package:locomotive/features/main_app/domain/entities/train.dart";

void main() {
  group("isValid", () {
    test("returns true for valid train", () {
      const t = Train(
        caboosePosition: Coordinate(Date(2000), TrainTrack.E),
        locomotivePosition: Coordinate(Date(2050), TrainTrack.E),
        trainName: "A",
        color: TrainColor.amber,
      );
      assert(t.isValid);
    });

    test("returns false for invalid trains", () {
      const t1 = Train(
        caboosePosition: Coordinate(Date(2000), TrainTrack.E),
        locomotivePosition: Coordinate(Date(2050), TrainTrack.G),
        trainName: "A",
        color: TrainColor.amber,
      );
      const t2 = Train(
        caboosePosition: Coordinate(Date(2080), TrainTrack.E),
        locomotivePosition: Coordinate(Date(2050), TrainTrack.E),
        trainName: "A",
        color: TrainColor.amber,
      );
      const t3 = Train(
        caboosePosition: Coordinate(Date(2050), TrainTrack.E),
        locomotivePosition: Coordinate(Date(2050), TrainTrack.E),
        trainName: "A",
        color: TrainColor.amber,
      );
      const t4 = Train(
        caboosePosition: Coordinate(Date(2080), TrainTrack.E),
        locomotivePosition: Coordinate(Date(2050), TrainTrack.G),
        trainName: "A",
        color: TrainColor.amber,
      );
      assert(!t1.isValid && !t2.isValid && !t3.isValid && !t4.isValid);
    });
  });
}
