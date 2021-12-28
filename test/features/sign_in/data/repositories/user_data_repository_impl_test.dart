import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/core/services/connectivity_service.dart";
import "package:locomotive/features/sign_in/data/datasources/firebase_auth_datasource.dart";
import "package:locomotive/features/sign_in/data/repositories/user_data_repository_impl.dart";
import "package:locomotive/features/sign_in/domain/entities/user_data.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "user_data_repository_impl_test.mocks.dart";

@GenerateMocks(
  [FirebaseAuthADataSource, ConnectivityService, UserDataRepositoryImpl],
)
void main() {
  FirebaseAuthADataSource firebaseAuthDataSource =
      MockFirebaseAuthADataSource();
  ConnectivityService connectivityService = MockConnectivityService();
  UserDataRepositoryImpl userDataRepositoryImpl = MockUserDataRepositoryImpl();

  setUp(() {
    firebaseAuthDataSource = MockFirebaseAuthADataSource();
    connectivityService = MockConnectivityService();
    userDataRepositoryImpl = UserDataRepositoryImpl(
      firebaseAuthDataSource: firebaseAuthDataSource,
      connectivityService: connectivityService,
    );
  });

  group("getAuthState", () {
    test("should return NetworkFailure when not connected to the internet",
        () async {
      // arrange
      when(connectivityService.networkAccessible)
          .thenAnswer((_) async => false);
      // act
      final authState = await userDataRepositoryImpl.getAuthState();
      // assert
      verify(connectivityService.networkAccessible);
      verifyNoMoreInteractions(firebaseAuthDataSource);
      verifyNoMoreInteractions(connectivityService);
      expect(
        authState,
        equals(Left<NetworkFailure, UserData>(NetworkFailure())),
      );
    });

    test("should return UserData when connected to the internet", () async {
      // arrange
      when(connectivityService.networkAccessible).thenAnswer((_) async => true);
      when(firebaseAuthDataSource.getUserData()).thenAnswer(
        (_) async =>
            const UserData(uid: "uid", emailVerificationNecessary: false),
      );
      // act
      final authState = await userDataRepositoryImpl.getAuthState();
      // assert
      verify(connectivityService.networkAccessible);
      verify(firebaseAuthDataSource.getUserData());
      verifyNoMoreInteractions(connectivityService);
      verifyNoMoreInteractions(firebaseAuthDataSource);
      expect(
        authState,
        equals(
          const Right<NetworkFailure, UserData>(
            UserData(uid: "uid", emailVerificationNecessary: false),
          ),
        ),
      );
    });

    test("should return UnexpectedFailure on exception", () async {
      // arrange
      when(connectivityService.networkAccessible).thenAnswer((_) async => true);
      when(firebaseAuthDataSource.getUserData())
          .thenThrow(const FormatException());
      // act
      final authState = await userDataRepositoryImpl.getAuthState();
      // assert
      verify(connectivityService.networkAccessible);
      verify(firebaseAuthDataSource.getUserData());
      verifyNoMoreInteractions(connectivityService);
      verifyNoMoreInteractions(firebaseAuthDataSource);
      assert(
        authState.fold(
          (l) => l is UnexpectedFailure,
          (r) => false,
        ),
      );
    });
  });
}
