import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_test/flutter_test.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/core/services/connectivity_service.dart";
import "package:locomotive/features/sign_in/data/datasources/firebase_auth_datasource.dart";
import "package:locomotive/features/sign_in/data/repositories/authentication_repository_impl.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "authentication_repository_impl_test.mocks.dart";

@GenerateMocks(
  [FirebaseAuthADataSource, ConnectivityService, AuthenticationRepositoryImpl],
)
void main() {
  FirebaseAuthADataSource firebaseAuthDataSource =
      MockFirebaseAuthADataSource();
  ConnectivityService connectivityService = MockConnectivityService();
  AuthenticationRepositoryImpl authenticationRepositoryImpl =
      MockAuthenticationRepositoryImpl();

  setUp(() {
    firebaseAuthDataSource = MockFirebaseAuthADataSource();
    connectivityService = MockConnectivityService();
    authenticationRepositoryImpl = AuthenticationRepositoryImpl(
      firebaseAuthDataSource: firebaseAuthDataSource,
      connectivityService: connectivityService,
    );
  });

  group("<shared logic>", () {
    test("should return NetworkFailure when not connected to the internet",
        () async {
      // arrange
      when(connectivityService.networkAccessible)
          .thenAnswer((_) async => false);
      // act
      final authState = await authenticationRepositoryImpl.signInWithEmail(
        email: "abc@xyz.com",
        password: "pass",
      );
      // assert
      verify(connectivityService.networkAccessible);
      verifyNoMoreInteractions(firebaseAuthDataSource);
      verifyNoMoreInteractions(connectivityService);
      expect(
        authState,
        equals(NetworkFailure()),
      );
    });

    test("should return UserCreationFailure when user creation fails",
        () async {
      // arrange
      when(connectivityService.networkAccessible).thenAnswer((_) async => true);
      when(
        firebaseAuthDataSource.signInWithEmail(
          "abc@xyz.com",
          "pass",
        ),
      ).thenThrow(FirebaseAuthException(code: "user-not-found"));
      // act
      final authState = await authenticationRepositoryImpl.signInWithEmail(
        email: "abc@xyz.com",
        password: "pass",
      );
      // assert
      verify(connectivityService.networkAccessible);
      verify(
        firebaseAuthDataSource.signInWithEmail(
          "abc@xyz.com",
          "pass",
        ),
      ).called(1);
      verifyNoMoreInteractions(firebaseAuthDataSource);
      verifyNoMoreInteractions(connectivityService);
      expect(
        authState,
        equals(UserCreationFailure(UserCreationIssue.userNotFound)),
      );
    });

    test("should return UnexpectedFailure when user creation fails", () async {
      // arrange
      when(connectivityService.networkAccessible).thenAnswer((_) async => true);
      when(
        firebaseAuthDataSource.signInWithEmail(
          "abc@xyz.com",
          "pass",
        ),
      ).thenThrow(const FormatException());
      // act
      final authState = await authenticationRepositoryImpl.signInWithEmail(
        email: "abc@xyz.com",
        password: "pass",
      );
      // assert
      verify(connectivityService.networkAccessible);
      verify(
        firebaseAuthDataSource.signInWithEmail(
          "abc@xyz.com",
          "pass",
        ),
      ).called(1);
      verifyNoMoreInteractions(firebaseAuthDataSource);
      verifyNoMoreInteractions(connectivityService);
      assert(authState is UnexpectedFailure);
    });
  });

  group("signInWithEmail", () {
    test("should call signInWithEmail on firebaseAuthDataSource", () async {
      // arrange
      when(connectivityService.networkAccessible).thenAnswer((_) async => true);
      when(
        firebaseAuthDataSource.signInWithEmail(
          "abc@xyz.com",
          "pass",
        ),
      ).thenAnswer((_) async {});
      // act
      final authState = await authenticationRepositoryImpl.signInWithEmail(
        email: "abc@xyz.com",
        password: "pass",
      );
      // assert
      verify(connectivityService.networkAccessible);
      verify(
        firebaseAuthDataSource.signInWithEmail(
          "abc@xyz.com",
          "pass",
        ),
      );
      verifyNoMoreInteractions(firebaseAuthDataSource);
      verifyNoMoreInteractions(connectivityService);
      expect(authState, null);
    });
  });

  group("signUpWithEmail", () {
    test("should call signUpWithEmail on firebaseAuthDataSource", () async {
      // arrange
      when(connectivityService.networkAccessible).thenAnswer((_) async => true);
      when(
        firebaseAuthDataSource.signUpWithEmail(
          "abc@xyz.com",
          "pass",
          "A. P.",
        ),
      ).thenAnswer((_) async {});
      // act
      final authState = await authenticationRepositoryImpl.signUpWithEmail(
        email: "abc@xyz.com",
        password: "pass",
        displayName: "A. P.",
      );
      // assert
      verify(connectivityService.networkAccessible);
      verify(
        firebaseAuthDataSource.signUpWithEmail(
          "abc@xyz.com",
          "pass",
          "A. P.",
        ),
      );
      verifyNoMoreInteractions(firebaseAuthDataSource);
      verifyNoMoreInteractions(connectivityService);
      expect(authState, null);
    });
  });

  group("signInWithGoogle", () {
    test("should call signInWithGoogle on firebaseAuthDataSource", () async {
      // arrange
      when(connectivityService.networkAccessible).thenAnswer((_) async => true);
      when(
        firebaseAuthDataSource.signInWithGoogle(),
      ).thenAnswer((_) async {});
      // act
      final authState = await authenticationRepositoryImpl.signInWithGoogle();
      // assert
      verify(connectivityService.networkAccessible);
      verify(firebaseAuthDataSource.signInWithGoogle());
      verifyNoMoreInteractions(firebaseAuthDataSource);
      verifyNoMoreInteractions(connectivityService);
      expect(authState, null);
    });
  });
}
