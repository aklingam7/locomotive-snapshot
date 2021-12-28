import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/main_app/domain/entities/app_data.dart";
import "package:locomotive/features/main_app/domain/repositories/app_data_repository.dart";

class UUpdateLocalData {
  UUpdateLocalData(this.repository);

  final AppDataRepository repository;

  Future<Failure?> call(AppData appData) {
    return repository.updateAppData(appData);
  }
}
