import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_test/flutter_test.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:locomotive/core/errors/exceptions.dart";
import "package:locomotive/features/sign_in/data/datasources/firebase_auth_datasource.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "firebase_auth_datasource_test.mocks.dart";

@GenerateMocks(
  [
    FirebaseAuth,
    User,
    UserCredential,
    GoogleSignIn,
    GoogleSignInAccount,
    GoogleSignInAuthentication
  ],
)
void main() {
  MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
  GoogleSignIn mockGoogleSignIn = MockGoogleSignIn();
  FirebaseAuthDataSourceImpl datasource = FirebaseAuthDataSourceImpl(
    mockFirebaseAuth,
    googleSignIn: mockGoogleSignIn,
  );
  User user = MockUser();
  final UserCredential userCredential = MockUserCredential();
  final GoogleSignInAuthentication mockGoogleSignInAuthentication =
      MockGoogleSignInAuthentication();
  final GoogleSignInAccount mockGoogleSignInAccount = MockGoogleSignInAccount();
  when(mockGoogleSignInAuthentication.accessToken).thenReturn("token");
  when(mockGoogleSignInAuthentication.idToken).thenReturn("idToken");
  when(mockGoogleSignInAccount.authentication)
      .thenAnswer((_) async => mockGoogleSignInAuthentication);

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    datasource = FirebaseAuthDataSourceImpl(
      mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
    user = MockUser();
    when(user.reload()).thenAnswer((_) async {});
    when(mockFirebaseAuth.currentUser).thenReturn(user);
  });

  group("getUserData", () {
    test("should return UserData", () async {
      // arrange
      when(user.uid).thenReturn("test_uid");
      when(user.emailVerified).thenReturn(false);
      // act
      final result = await datasource.getUserData();
      // assert
      expect(result.uid, "test_uid");
      expect(result.emailVerificationNecessary, true);
    });
  });

  group("signInWithEmail", () {
    const email = "abc@xyz.com";
    const password = "pass";

    test("should return null if signInWithEmail succeeds", () async {
      // arrange
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => userCredential);
      // act
      await datasource.signInWithEmail(email, password);
      // assert
      verify(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).called(1);
      verify(mockFirebaseAuth.currentUser);
      verify(user.reload());
      verifyNoMoreInteractions(mockFirebaseAuth);
      verifyNoMoreInteractions(user);
    });

    test("should not not catch FirebaseAuthException", () async {
      // arrange
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenThrow(FirebaseAuthException(code: "code"));
      // assert
      expect(
        () async => datasource.signInWithEmail(email, password),
        throwsA(const TypeMatcher<FirebaseAuthException>()),
      );
      verify(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockFirebaseAuth);
      verifyNoMoreInteractions(user);
    });
  });

  group("signUpWithEmail", () {
    const displayName = "A. P.";
    const email = "abc@xyz.com";
    const password = "pass";

    test("should return null if signUpWithEmail succeeds", () async {
      // arrange
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => userCredential);
      when(user.updateDisplayName(displayName)).thenAnswer((_) async {});
      when(user.sendEmailVerification()).thenAnswer((_) async {});
      // act
      await datasource.signUpWithEmail(email, password, displayName);
      // assert
      verify(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).called(1);
      verify(mockFirebaseAuth.currentUser);
      verify(user.updateDisplayName(displayName)).called(1);
      verify(user.reload());
      verify(user.sendEmailVerification()).called(1);
      verifyNoMoreInteractions(mockFirebaseAuth);
      verifyNoMoreInteractions(user);
    });

    test("should not not catch FirebaseAuthException", () async {
      // arrange
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenThrow(FirebaseAuthException(code: "code"));
      // assert
      expect(
        () async => datasource.signUpWithEmail(email, password, displayName),
        throwsA(const TypeMatcher<FirebaseAuthException>()),
      );
      verify(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockFirebaseAuth);
      verifyNoMoreInteractions(user);
    });
  });

  group("signInWithGoogle", () {
    test("should return null if signInWithGoogle succeeds", () async {
      // arrange
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => userCredential);
      // act
      await datasource.signInWithGoogle();
      // assert
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
      verify(mockFirebaseAuth.currentUser);
      verify(user.reload());
      verifyNoMoreInteractions(mockFirebaseAuth);
      verifyNoMoreInteractions(user);
    });

    test("should not not catch FirebaseAuthException", () async {
      // arrange
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockFirebaseAuth.signInWithCredential(any))
          .thenThrow(FirebaseAuthException(code: "code"));
      // assert
      expect(
        () async => datasource.signInWithGoogle(),
        throwsA(const TypeMatcher<FirebaseAuthException>()),
      );
      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNoMoreInteractions(mockFirebaseAuth);
      verifyNoMoreInteractions(user);
    });

    test("should not not catch UserInterruptionException", () async {
      // arrange
      when(mockGoogleSignIn.signIn()).thenThrow(UserInterruptionException());
      // assert
      expect(
        () async => datasource.signInWithGoogle(),
        throwsA(const TypeMatcher<UserInterruptionException>()),
      );
      verifyNoMoreInteractions(mockFirebaseAuth);
      verifyNoMoreInteractions(user);
    });
  });
}
