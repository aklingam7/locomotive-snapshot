import "package:equatable/equatable.dart";

class UserData extends Equatable {
  const UserData({
    required this.uid,
    required this.emailVerificationNecessary,
  });

  final String? uid;
  final bool emailVerificationNecessary;

  @override
  List<Object?> get props => [uid, emailVerificationNecessary];
}
