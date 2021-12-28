import "package:dartz/dartz.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/main_app/domain/entities/app_data.dart";

abstract class AppDataRepository {
  Future<Either<Failure, AppData>> getAppData();
  Future<Failure?> updateAppData(AppData appData);
  Future<Either<Failure, AppData?>> syncAppData();
  Future<Failure?> deleteAppData();
}
