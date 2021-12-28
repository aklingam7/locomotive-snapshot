import "package:firebase_auth/firebase_auth.dart";
import "package:locomotive/features/main_app/domain/entities/user_profile.dart";

abstract class FirebaseAuthUDataSource {
  Future<UserProfile> getUserProfile();
  Future<void> signOut();
}

class FirebaseAuthUDataSourceImpl implements FirebaseAuthUDataSource {
  FirebaseAuthUDataSourceImpl(this.firebaseAuthService);

  final FirebaseAuth firebaseAuthService;

  @override
  Future<UserProfile> getUserProfile() async {
    await firebaseAuthService.currentUser?.reload();
    final currentUser = firebaseAuthService.currentUser;
    if (currentUser == null) throw UnsupportedError("User is not signed in");
    return UserProfile(
      name: currentUser.displayName!,
      uid: currentUser.uid,
      creationTime: currentUser.metadata.creationTime!,
    );
  }

  @override
  Future<void> signOut() async {
    await firebaseAuthService.currentUser?.reload();
    final currentUser = firebaseAuthService.currentUser;
    if (currentUser == null) throw UnsupportedError("User is not signed in");
    return firebaseAuthService.signOut();
  }
}
