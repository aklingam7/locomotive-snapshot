part of "auth_bloc.dart";

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class GetAuthData extends AuthEvent {}

class SignInWithGoogle extends AuthEvent {}

class SignInWithEmail extends AuthEvent {
  const SignInWithEmail({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class SignUpWithEmail extends AuthEvent {
  const SignUpWithEmail({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;

  @override
  List<Object> get props => [email, password];
}
