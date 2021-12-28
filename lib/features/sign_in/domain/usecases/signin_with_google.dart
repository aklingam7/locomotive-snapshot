import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/sign_in/domain/repositories/authentication_repository.dart";

class USignInWithGoogle {
  USignInWithGoogle(this.repository);

  final AuthenticationRepository repository;

  Future<Failure?> call() {
    return repository.signInWithGoogle();
  }
}
