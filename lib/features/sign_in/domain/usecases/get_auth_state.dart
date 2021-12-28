import "package:dartz/dartz.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/sign_in/domain/entities/user_data.dart";
import "package:locomotive/features/sign_in/domain/repositories/user_data_repository.dart";

class UGetAuthState {
  UGetAuthState(this.repository);

  final UserDataRepository repository;

  Future<Either<Failure, UserData>> call() {
    return repository.getAuthState();
  }
}
