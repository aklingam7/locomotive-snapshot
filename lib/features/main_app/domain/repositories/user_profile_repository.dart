import "package:dartz/dartz.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/main_app/domain/entities/user_profile.dart";

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();
  Future<Failure?> signOut();
}
