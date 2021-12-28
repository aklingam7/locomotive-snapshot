import "package:dartz/dartz.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/core/services/connectivity_service.dart";
import "package:locomotive/features/main_app/data/datasources/app_data_local_datasource.dart";
import "package:locomotive/features/main_app/data/datasources/firebase_auth_datasource.dart";
import "package:locomotive/features/main_app/domain/entities/user_profile.dart";
import "package:locomotive/features/main_app/domain/repositories/user_profile_repository.dart";

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl({
    required this.appDataLocalDataSource,
    required this.firebaseAuthUDataSource,
    required this.connectivityService,
  });

  final FirebaseAuthUDataSource firebaseAuthUDataSource;
  final AppDataLocalDataSource appDataLocalDataSource;
  final ConnectivityService connectivityService;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    if (await connectivityService.networkAccessible) {
      try {
        return Right(await firebaseAuthUDataSource.getUserProfile());
      } catch (e, s) {
        return Left(UnexpectedFailure(exception: e, stackTrace: s));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Failure?> signOut() async {
    if (await connectivityService.networkAccessible) {
      try {
        await firebaseAuthUDataSource.signOut();
        await appDataLocalDataSource.deleteAppData();
      } catch (e, s) {
        return UnexpectedFailure(exception: e, stackTrace: s);
      }
    } else {
      return NetworkFailure();
    }
  }
}
