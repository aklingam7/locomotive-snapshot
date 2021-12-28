import "package:dartz/dartz.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/main_app/domain/entities/user_profile.dart";
import "package:locomotive/features/main_app/domain/repositories/user_profile_repository.dart";

class UGetUserProfile {
  UGetUserProfile(this.repository);

  final UserProfileRepository repository;

  Future<Either<Failure, UserProfile>> call() {
    return repository.getUserProfile();
  }
}
