import "package:dartz/dartz.dart";
import "package:flutter/foundation.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/core/services/connectivity_service.dart";
import "package:locomotive/features/main_app/data/datasources/app_data_firestore_datasource.dart";
import "package:locomotive/features/main_app/data/datasources/app_data_local_datasource.dart";
import "package:locomotive/features/main_app/domain/entities/app_data.dart";
import "package:locomotive/features/main_app/domain/repositories/app_data_repository.dart";

class AppDataRepositoryImpl implements AppDataRepository {
  AppDataRepositoryImpl({
    required this.firestoreDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  final AppDataLocalDataSource localDataSource;
  final AppDataFirestoreDataSource firestoreDataSource;
  final ConnectivityService connectivityService;

  @override
  Future<Either<Failure, AppData>> getAppData() async {
    final initialAppData = AppData(
      trains: const [],
      freightCars: const [],
      source: AppDataSource.initial,
    );
    try {
      if (await connectivityService.networkAccessible) {
        final syncResult = await syncAppData();
        return syncResult.fold(
          (l) => Left(UnexpectedFailure(exception: "Sync failed")),
          (r) => Right(
            r != null
                ? AppData(
                    trains: r.trains,
                    freightCars: r.freightCars,
                    source: AppDataSource.server,
                    lastChanged: r.lastChanged,
                  )
                : initialAppData,
          ),
        );
      }
      final data = await localDataSource.getAppData();
      if (data != null && data.isValid) {
        return Right(data);
      } else {
        if (await updateAppData(initialAppData) == null) {
          return Right(initialAppData);
        } else {
          return Left(UnexpectedFailure());
        }
      }
    } catch (e, s) {
      return Left(UnexpectedFailure(exception: e, stackTrace: s));
    }
  }

  @override
  Future<Failure?> updateAppData(AppData appData) async {
    final data = AppData(
      trains: appData.trains,
      freightCars: appData.freightCars,
      source: appData.source,
    );
    if (!data.isValid) return AppDataFailure();
    try {
      await localDataSource.updateAppData(data);
    } catch (e, s) {
      return UnexpectedFailure(exception: e, stackTrace: s);
    }
  }

  @override
  Future<Either<Failure, AppData?>> syncAppData() async {
    try {
      if (await connectivityService.networkAccessible) {
        final localData = await localDataSource.getAppData();
        final serverData = await firestoreDataSource.getAppData();
        if (kDebugMode) {
          print("localData: $localData");
          print("serverData: $serverData");
        }
        if (localData != null &&
            localData.isValid &&
            serverData != null &&
            serverData.isValid) {
          if (serverData.lastChanged.millisecondsSinceEpoch >
              localData.lastChanged.millisecondsSinceEpoch) {
            await localDataSource.updateAppData(serverData);
            return Right(serverData);
          } else {
            await firestoreDataSource.updateAppData(localData);
            return Right(localData);
          }
        } else if (localData != null &&
            localData.isValid &&
            serverData == null) {
          await firestoreDataSource.updateAppData(localData);
          return Right(localData);
        } else if (serverData != null &&
            serverData.isValid &&
            localData == null) {
          await localDataSource.updateAppData(serverData);
          return Right(serverData);
        } else if (localData == null && serverData == null) {
          return const Right(null);
        } else {
          return Left(UnexpectedFailure());
        }
      } else {
        return Left(NetworkFailure());
      }
    } catch (e, s) {
      return Left(UnexpectedFailure(exception: e, stackTrace: s));
    }
  }

  @override
  Future<Failure?> deleteAppData() async {
    try {
      await localDataSource.deleteAppData();
      await firestoreDataSource.deleteAppData();
    } catch (e, s) {
      return UnexpectedFailure(exception: e, stackTrace: s);
    }
  }
}
