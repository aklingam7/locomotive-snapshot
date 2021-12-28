import "package:flutter_test/flutter_test.dart";
import "package:locomotive/features/main_app/domain/entities/date.dart";

void main() {
  test("fromDateTime should be inverse of toDateTime", () {
    final dt = DateTime.now();
    final date = Date.fromDateTime(dt);
    assert(date.toDateTime().difference(dt).inDays == 0);
  });
}
