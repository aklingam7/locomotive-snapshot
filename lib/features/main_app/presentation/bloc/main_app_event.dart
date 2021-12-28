part of "main_app_bloc.dart";

abstract class MainAppEvent extends Equatable {
  const MainAppEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppDataE extends MainAppEvent {}

class CreateTrainE extends MainAppEvent {
  const CreateTrainE(this.train, this.appData);

  final Train train;
  final AppData? appData;

  @override
  List<Object?> get props => [train, appData];
}

class UpdateAppDataE extends MainAppEvent {
  const UpdateAppDataE(this.appData, this.oldAppData);

  final AppData appData;
  final AppData oldAppData;

  @override
  List<Object> get props => [appData, oldAppData];
}

class DeleteTrainE extends MainAppEvent {
  const DeleteTrainE(this.train, this.appData);

  final Train train;
  final AppData? appData;

  @override
  List<Object?> get props => [train, appData];
}

class AddCoalE extends MainAppEvent {
  const AddCoalE(this.numCoal, this.carPosition, this.appData);

  final int numCoal;
  final Coordinate carPosition;
  final AppData? appData;

  @override
  List<Object?> get props => [numCoal, appData];
}

class SyncAppDataE extends MainAppEvent {}

class OpenSettingsE extends MainAppEvent {}

class DeleteAppDataE extends MainAppEvent {}

class SignOutE extends MainAppEvent {}
