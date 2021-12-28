import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/sign_in/domain/repositories/authentication_repository.dart";

class USignUpWithEmail {
  USignUpWithEmail(this.repository);

  final AuthenticationRepository repository;

  Future<Failure?> call({
    required String displayName,
    required String email,
    required String password,
  }) {
    return repository.signUpWithEmail(
      displayName: displayName,
      email: email,
      password: password,
    );
  }
}
