import "package:dartz/dartz.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/sign_in/domain/entities/user_data.dart";

abstract class UserDataRepository {
  Future<Either<Failure, UserData>> getAuthState();
}
