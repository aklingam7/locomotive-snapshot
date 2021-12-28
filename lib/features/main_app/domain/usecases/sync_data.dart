import "package:dartz/dartz.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/main_app/domain/entities/app_data.dart";
import "package:locomotive/features/main_app/domain/repositories/app_data_repository.dart";

class USyncData {
  USyncData(this.repository);

  final AppDataRepository repository;

  Future<Either<Failure, AppData?>> call() {
    return repository.syncAppData();
  }
}
