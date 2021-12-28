import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/main_app/domain/repositories/user_profile_repository.dart";

class USignOut {
  USignOut(this.repository);

  final UserProfileRepository repository;

  Future<Failure?> call() {
    return repository.signOut();
  }
}
