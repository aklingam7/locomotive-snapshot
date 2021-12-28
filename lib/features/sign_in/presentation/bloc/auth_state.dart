part of "auth_bloc.dart";

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class ShowSplashScreen extends AuthState {}

class Loading extends AuthState {}

class NoUser extends AuthState {}

class VerificationNeeded extends AuthState {}

class GoToApp extends AuthState {}

class NoInternetConnection extends AuthState {}

class AuthenticationError extends AuthState {
  const AuthenticationError(this.issue);

  final UserCreationIssue issue;

  @override
  List<Object> get props => [issue];
}

class UnexpectedError extends AuthState {
  const UnexpectedError({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}
