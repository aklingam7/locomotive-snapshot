import "package:equatable/equatable.dart";
import "package:flutter/foundation.dart";

abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

class NetworkFailure extends Failure {}

class UserCreationFailure extends Failure {
  UserCreationFailure(this.issue);

  final UserCreationIssue issue;

  @override
  List<Object?> get props => [issue];
}

enum UserCreationIssue {
  invalidEmail,
  emailAlreadyInUse,
  userNotFound,
  userDisabled,
  accountExistsWithEmail,
  weakPassword,
  wrongPassword,
  userInterruption,
  other,
}

class AppDataFailure extends Failure {}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({this.exception, this.stackTrace}) {
    if (kDebugMode) {
      print("* Created UnexpectedFailure: * \n$exception\n\n$stackTrace");
    }
  }

  final Object? exception;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [exception, stackTrace];
}
