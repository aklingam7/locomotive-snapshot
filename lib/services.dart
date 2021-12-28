import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_analytics/firebase_analytics.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "package:get_it/get_it.dart";
import "package:locomotive/core/services/connectivity_service.dart";
import "package:locomotive/core/services/user_config_service.dart";
import "package:locomotive/features/main_app/data/datasources/app_data_firestore_datasource.dart";
import "package:locomotive/features/main_app/data/datasources/app_data_local_datasource.dart";
import "package:locomotive/features/main_app/data/datasources/firebase_auth_datasource.dart";
import "package:locomotive/features/main_app/data/repositories/app_data_repository_impl.dart";
import "package:locomotive/features/main_app/data/repositories/user_profile_repository_impl.dart";
import "package:locomotive/features/main_app/domain/repositories/app_data_repository.dart";
import "package:locomotive/features/main_app/domain/repositories/user_profile_repository.dart";
import "package:locomotive/features/main_app/domain/usecases/delete_app_data.dart";
import "package:locomotive/features/main_app/domain/usecases/get_app_data.dart";
import "package:locomotive/features/main_app/domain/usecases/get_user_profile.dart";
import "package:locomotive/features/main_app/domain/usecases/sign_out.dart";
import "package:locomotive/features/main_app/domain/usecases/sync_data.dart";
import "package:locomotive/features/main_app/domain/usecases/update_local_data.dart";
import "package:locomotive/features/sign_in/data/datasources/firebase_auth_datasource.dart";
import "package:locomotive/features/sign_in/data/repositories/authentication_repository_impl.dart";
import "package:locomotive/features/sign_in/data/repositories/user_data_repository_impl.dart";
import "package:locomotive/features/sign_in/domain/repositories/authentication_repository.dart";
import "package:locomotive/features/sign_in/domain/repositories/user_data_repository.dart";
import "package:locomotive/features/sign_in/domain/usecases/get_auth_state.dart";
import "package:locomotive/features/sign_in/domain/usecases/signin_with_email.dart";
import "package:locomotive/features/sign_in/domain/usecases/signin_with_google.dart";
import "package:locomotive/features/sign_in/domain/usecases/signup_with_email.dart";
import "package:locomotive/firebase_options.dart";
import "package:shared_preferences/shared_preferences.dart";

final sl = GetIt.instance;

Future<void> initServices({bool? useFireStoreEmulator}) async {
  //! Firebase
  final firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  sl.registerLazySingleton(() => firebaseApp);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAnalytics.instance);
  if (useFireStoreEmulator ?? kDebugMode) {
    sl<FirebaseFirestore>().useFirestoreEmulator("localhost", 8080);
  }

  //! Main App
  sl.registerLazySingleton(() => UGetAppData(sl()));
  sl.registerLazySingleton(() => UUpdateLocalData(sl()));
  sl.registerLazySingleton(() => USyncData(sl()));
  sl.registerLazySingleton(() => UGetUserProfile(sl()));
  sl.registerLazySingleton(() => USignOut(sl()));
  sl.registerLazySingleton(() => UDeleteAppData(sl()));
  sl.registerLazySingleton<AppDataRepository>(
    () => AppDataRepositoryImpl(
      localDataSource: sl(),
      firestoreDataSource: sl(),
      connectivityService: sl(),
    ),
  );
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      firebaseAuthUDataSource: sl(),
      appDataLocalDataSource: sl(),
      connectivityService: sl(),
    ),
  );
  sl.registerLazySingleton<AppDataLocalDataSource>(
    () => AppDataLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AppDataFirestoreDataSource>(
    () => AppDataFirestoreDataSourceImpl(
      firebaseAuthService: sl(),
      firebaseFirestoreService: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseAuthUDataSource>(
    () => FirebaseAuthUDataSourceImpl(sl()),
  );

  //! Sign In
  sl.registerLazySingleton(() => UGetAuthState(sl()));
  sl.registerLazySingleton(() => USignInWithEmail(sl()));
  sl.registerLazySingleton(() => USignUpWithEmail(sl()));
  sl.registerLazySingleton(() => USignInWithGoogle(sl()));
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      firebaseAuthDataSource: sl(),
      connectivityService: sl(),
    ),
  );
  sl.registerLazySingleton<UserDataRepository>(
    () => UserDataRepositoryImpl(
      firebaseAuthDataSource: sl(),
      connectivityService: sl(),
    ),
  );
  sl.registerLazySingleton<FirebaseAuthADataSource>(
    () => FirebaseAuthDataSourceImpl(sl()),
  );

  //! Services
  sl.registerLazySingleton<UserConfigService>(
    () => UserConfigServiceImpl(sl()),
  );
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
