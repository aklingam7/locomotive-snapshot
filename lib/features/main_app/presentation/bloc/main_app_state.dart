part of "main_app_bloc.dart";

abstract class MainAppState extends Equatable {
  const MainAppState();

  @override
  List<Object?> get props => [];
}

class LoadingS extends MainAppState {}

class UpdateAppDataS extends MainAppState {
  const UpdateAppDataS(this.appData);

  final AppData appData;

  @override
  List<Object> get props => [appData];
}

class ReBuildS extends MainAppState {}

class OpenSettingsS extends MainAppState {
  const OpenSettingsS(this.userProfile);

  final UserProfile userProfile;

  @override
  List<Object> get props => [userProfile];
}

class ErrorS extends MainAppState {
  const ErrorS({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class GoToLoginS extends MainAppState {}
