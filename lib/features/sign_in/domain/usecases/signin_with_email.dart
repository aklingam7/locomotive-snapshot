import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/sign_in/domain/repositories/authentication_repository.dart";

class USignInWithEmail {
  USignInWithEmail(this.repository);

  final AuthenticationRepository repository;

  Future<Failure?> call({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
