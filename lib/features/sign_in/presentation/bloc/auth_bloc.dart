import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/features/sign_in/domain/usecases/get_auth_state.dart";
import "package:locomotive/features/sign_in/domain/usecases/signin_with_email.dart";
import "package:locomotive/features/sign_in/domain/usecases/signin_with_google.dart";
import "package:locomotive/features/sign_in/domain/usecases/signup_with_email.dart";

part "auth_event.dart";
part "auth_state.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.uGetAuthState,
    required this.uSignInWithEmail,
    required this.uSignUpWithEmail,
    required this.uSignInWithGoogle,
  }) : super(ShowSplashScreen()) {
    on<AuthEvent>((event, emit) async {
      switch (event.runtimeType) {
        case GetAuthData:
          final result = await uGetAuthState();
          emit(
            result.fold(
              (failure) {
                switch (failure.runtimeType) {
                  case NetworkFailure:
                    return NoInternetConnection();
                  default:
                    return const UnexpectedError();
                }
              },
              (authState) {
                if (authState.uid != null &&
                    !authState.emailVerificationNecessary) {
                  return GoToApp();
                } else if (authState.emailVerificationNecessary) {
                  return VerificationNeeded();
                } else {
                  return NoUser();
                }
              },
            ),
          );
          break;
        case SignInWithGoogle:
          emit(Loading());
          final result = await uSignInWithGoogle();
          if (result == null) {
            emit(GoToApp());
          } else {
            switch (result.runtimeType) {
              case NetworkFailure:
                emit(NoInternetConnection());
                break;
              case UserCreationFailure:
                emit(
                  AuthenticationError(
                    (result as UserCreationFailure).issue,
                  ),
                );
                break;
              default:
                emit(const UnexpectedError());
                break;
            }
          }
          break;
        case SignInWithEmail:
          emit(Loading());
          final result = await uSignInWithEmail(
            email: (event as SignInWithEmail).email,
            password: event.password,
          );
          if (result == null) {
            emit(GoToApp());
          } else {
            switch (result.runtimeType) {
              case NetworkFailure:
                emit(NoInternetConnection());
                break;
              case UserCreationFailure:
                emit(
                  AuthenticationError(
                    (result as UserCreationFailure).issue,
                  ),
                );
                break;
              default:
                emit(const UnexpectedError());
                break;
            }
          }
          break;
        case SignUpWithEmail:
          emit(Loading());
          final result = await uSignUpWithEmail(
            email: (event as SignUpWithEmail).email,
            password: event.password,
            displayName: event.displayName,
          );
          if (result == null) {
            emit(VerificationNeeded());
          } else {
            switch (result.runtimeType) {
              case NetworkFailure:
                emit(NoInternetConnection());
                break;
              case UserCreationFailure:
                emit(
                  AuthenticationError(
                    (result as UserCreationFailure).issue,
                  ),
                );
                break;
              default:
                emit(const UnexpectedError());
                break;
            }
          }
          break;
        default:
          emit(const UnexpectedError());
          break;
      }
    });
  }

  final UGetAuthState uGetAuthState;
  final USignInWithEmail uSignInWithEmail;
  final USignUpWithEmail uSignUpWithEmail;
  final USignInWithGoogle uSignInWithGoogle;
}
