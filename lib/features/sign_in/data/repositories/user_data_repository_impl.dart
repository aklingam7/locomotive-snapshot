import "package:dartz/dartz.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/core/services/connectivity_service.dart";
import "package:locomotive/features/sign_in/data/datasources/firebase_auth_datasource.dart";
import "package:locomotive/features/sign_in/domain/entities/user_data.dart";
import "package:locomotive/features/sign_in/domain/repositories/user_data_repository.dart";

class UserDataRepositoryImpl implements UserDataRepository {
  UserDataRepositoryImpl({
    required this.firebaseAuthDataSource,
    required this.connectivityService,
  });

  final FirebaseAuthADataSource firebaseAuthDataSource;
  final ConnectivityService connectivityService;

  @override
  Future<Either<Failure, UserData>> getAuthState() async {
    if (await connectivityService.networkAccessible) {
      try {
        return Right(await firebaseAuthDataSource.getUserData());
      } catch (e, s) {
        return Left(UnexpectedFailure(exception: e, stackTrace: s));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
