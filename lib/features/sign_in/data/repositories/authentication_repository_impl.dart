import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:locomotive/core/errors/exceptions.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/core/services/connectivity_service.dart";
import "package:locomotive/features/sign_in/data/datasources/firebase_auth_datasource.dart";
import "package:locomotive/features/sign_in/domain/repositories/authentication_repository.dart";

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl({
    required this.firebaseAuthDataSource,
    required this.connectivityService,
  });

  final FirebaseAuthADataSource firebaseAuthDataSource;
  final ConnectivityService connectivityService;

  @override
  Future<Failure?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return authenticate(
      () => firebaseAuthDataSource.signInWithEmail(email, password),
    );
  }

  @override
  Future<Failure?> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    return authenticate(
      () => firebaseAuthDataSource.signUpWithEmail(
        email,
        password,
        displayName,
      ),
    );
  }

  @override
  Future<Failure?> signInWithGoogle() async {
    return authenticate(
      () => firebaseAuthDataSource.signInWithGoogle(),
    );
  }

  Future<Failure?> authenticate(Future<void> Function() f) async {
    if (await connectivityService.networkAccessible) {
      try {
        await f();
      } on FirebaseAuthException catch (e) {
        return firebaseAuthExceptionToFailure(e);
      } on UserInterruptionException {
        return UserCreationFailure(UserCreationIssue.userInterruption);
      } catch (e, s) {
        return UnexpectedFailure(exception: e, stackTrace: s);
      }
    } else {
      return NetworkFailure();
    }
  }

  Failure firebaseAuthExceptionToFailure(FirebaseAuthException e) {
    if (kDebugMode) {
      print("* FirebaseAuthException Thrown *");
      print(e.message);
    }
    const f = UserCreationFailure.new;
    switch (e.code) {
      case "invalid-email":
        return f(UserCreationIssue.invalidEmail);
      case "email-already-in-use":
        return f(UserCreationIssue.emailAlreadyInUse);
      case "user-not-found":
        return f(UserCreationIssue.userNotFound);
      case "user-disabled":
        return f(UserCreationIssue.userDisabled);
      case "account-exists-with-different-credential":
        return f(UserCreationIssue.accountExistsWithEmail);
      case "weak-password":
        return f(UserCreationIssue.weakPassword);
      case "wrong-password":
        return f(UserCreationIssue.wrongPassword);
      default:
        return f(UserCreationIssue.other);
    }
  }
}
