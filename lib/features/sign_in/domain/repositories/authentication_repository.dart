import "package:locomotive/core/errors/failures.dart";

abstract class AuthenticationRepository {
  Future<Failure?> signInWithGoogle();
  Future<Failure?> signInWithEmail({
    required String email,
    required String password,
  });
  Future<Failure?> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  });
}
