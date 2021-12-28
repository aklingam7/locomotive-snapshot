import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:locomotive/features/main_app/domain/entities/app_data.dart";
import "package:locomotive/features/main_app/domain/entities/coordinate.dart";
import "package:locomotive/features/main_app/domain/entities/freight_car.dart";
import "package:locomotive/features/main_app/domain/entities/train.dart";
import "package:locomotive/features/main_app/domain/entities/user_profile.dart";
import "package:locomotive/features/main_app/domain/usecases/delete_app_data.dart";
import "package:locomotive/features/main_app/domain/usecases/get_app_data.dart";
import "package:locomotive/features/main_app/domain/usecases/get_user_profile.dart";
import "package:locomotive/features/main_app/domain/usecases/sign_out.dart";
import "package:locomotive/features/main_app/domain/usecases/sync_data.dart";
import "package:locomotive/features/main_app/domain/usecases/update_local_data.dart";

part "main_app_event.dart";
part "main_app_state.dart";

class MainAppBloc extends Bloc<MainAppEvent, MainAppState> {
  MainAppBloc({
    required this.uGetAppData,
    required this.uUpdateLocalData,
    required this.uSyncData,
    required this.uGetUserProfile,
    required this.uSignOut,
    required this.uDeleteappData,
  }) : super(LoadingS()) {
    on<MainAppEvent>((event, emit) async {
      if (event is LoadAppDataE) {
        final result = await uGetAppData();
        if (result.isLeft()) {
          emit(const ErrorS());
        } else {
          emit(UpdateAppDataS(result.getOrElse(() => null!)));
          emit(ReBuildS());
        }
      } else if (event is CreateTrainE) {
        if (!event.train.isValid || event.appData == null) {
          emit(const ErrorS());
        } else {
          final AppData newData = AppData(
            trains: [...event.appData!.trains, event.train],
            freightCars: [...event.appData!.freightCars],
            source: AppDataSource.local,
          );
          if (!newData.isValid) {
            emit(const ErrorS());
          } else {
            final result = await uUpdateLocalData(newData);
            if (result != null) {
              emit(const ErrorS());
            } else {
              emit(UpdateAppDataS(newData));
              emit(ReBuildS());
            }
          }
        }
      } else if (event is UpdateAppDataE) {
        if (!event.appData.isValid) {
          emit(const ErrorS());
        } else {
          final result = await uUpdateLocalData(event.appData);
          if (result != null) {
            emit(const ErrorS());
          } else {
            emit(UpdateAppDataS(event.appData));
            emit(ReBuildS());
          }
        }
      } else if (event is DeleteTrainE) {
        if (!(event.appData?.isValid ?? false)) {
          emit(const ErrorS());
        } else {
          event.appData!.freightCars.removeWhere(
            (fc) =>
                fc.position.track == event.train.caboosePosition.track &&
                fc.position.date.day >= event.train.caboosePosition.date.day &&
                fc.position.date.day <= event.train.locomotivePosition.date.day,
          );
          final newData = AppData(
            freightCars: [...event.appData!.freightCars],
            source: AppDataSource.local,
            trains: event.appData!.trains
                .where((t) => t.trainName != event.train.trainName)
                .toList(),
          );
          final result = await uUpdateLocalData(newData);
          if (result != null) {
            emit(const ErrorS());
          } else {
            emit(UpdateAppDataS(newData));
            emit(ReBuildS());
          }
        }
      } else if (event is AddCoalE) {
        if (event.appData == null ||
            event.appData?.trainsMap[event.carPosition] == null) {
          emit(const ErrorS());
        } else {
          event.appData!.freightCars
              .removeWhere((fc) => fc.position == event.carPosition);
          final AppData newData = AppData(
            trains: [...event.appData!.trains],
            freightCars: [
              ...event.appData!.freightCars,
              if (event.numCoal >= 1)
                FreightCar(event.carPosition, event.numCoal),
            ],
            source: AppDataSource.local,
          );
          if (!newData.isValid) {
            emit(const ErrorS());
          } else {
            final result = await uUpdateLocalData(newData);
            if (result != null) {
              emit(const ErrorS());
            } else {
              emit(UpdateAppDataS(newData));
              emit(ReBuildS());
            }
          }
        }
      } else if (event is SyncAppDataE) {
        final result = await uSyncData();
        if (result.isLeft()) {
          emit(const ErrorS());
        } else {
          emit(UpdateAppDataS(result.getOrElse(() => null!)!));
          emit(ReBuildS());
        }
      } else if (event is DeleteAppDataE) {
        final result1 = await uDeleteappData();
        final result2 = await uGetAppData();
        if (result1 != null && result2.isLeft()) {
          emit(const ErrorS());
        } else {
          emit(UpdateAppDataS(result2.getOrElse(() => null!)));
          emit(ReBuildS());
        }
      } else if (event is OpenSettingsE) {
        final userProfile = await uGetUserProfile();
        emit(userProfile.fold((l) => const ErrorS(), (r) => OpenSettingsS(r)));
        if (userProfile.isRight()) emit(ReBuildS());
      } else if (event is SignOutE) {
        final result = await uSignOut();
        if (result != null) {
          emit(const ErrorS());
        } else {
          emit(GoToLoginS());
        }
      }
    });
  }

  final UGetAppData uGetAppData;
  final UUpdateLocalData uUpdateLocalData;
  final USyncData uSyncData;
  final UGetUserProfile uGetUserProfile;
  final USignOut uSignOut;
  final UDeleteAppData uDeleteappData;
}
