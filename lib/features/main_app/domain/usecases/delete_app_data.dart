import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/main_app/domain/repositories/app_data_repository.dart";

class UDeleteAppData {
  UDeleteAppData(this.repository);

  final AppDataRepository repository;

  Future<Failure?> call() {
    return repository.deleteAppData();
  }
}
