import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/foundation.dart';
import "package:google_sign_in/google_sign_in.dart";
import "package:locomotive/core/errors/exceptions.dart";
import "package:locomotive/features/sign_in/domain/entities/user_data.dart";

abstract class FirebaseAuthADataSource {
  Future<UserData> getUserData();

  // Throws [FirebaseAuthException]
  Future<void> signInWithEmail(String email, String password);

  // Throws [FirebaseAuthException]
  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );

  // Throws [FirebaseAuthException, UserInterruptionException]
  Future<void> signInWithGoogle();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthADataSource {
  FirebaseAuthDataSourceImpl(
    this.firebaseAuthService, {
    GoogleSignIn? googleSignIn,
  }) {
    this.googleSignIn = googleSignIn ?? GoogleSignIn();
  }

  final FirebaseAuth firebaseAuthService;
  late final GoogleSignIn googleSignIn;

  @override
  Future<UserData> getUserData() async {
    if (kIsWeb) {
      await firebaseAuthService.authStateChanges().first;
    }
    await firebaseAuthService.currentUser?.reload();
    final currentUser = firebaseAuthService.currentUser;
    if (currentUser == null) {
      return const UserData(uid: null, emailVerificationNecessary: false);
    }
    return currentUser.createUserData();
  }

  @override
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw UserInterruptionException();
    final GoogleSignInAuthentication googleAuth;
    googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await firebaseAuthService.signInWithCredential(credential);
    await firebaseAuthService.currentUser!.reload();
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await firebaseAuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await firebaseAuthService.currentUser!.reload();
  }

  @override
  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    await firebaseAuthService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await firebaseAuthService.currentUser!.updateDisplayName(
      displayName,
    );
    await firebaseAuthService.currentUser!.reload();
    await firebaseAuthService.currentUser!.sendEmailVerification();
  }
}

extension Constructor on User {
  UserData createUserData() {
    return UserData(uid: uid, emailVerificationNecessary: !emailVerified);
  }
}
