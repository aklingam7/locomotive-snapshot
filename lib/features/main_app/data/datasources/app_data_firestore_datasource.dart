import "dart:convert";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:locomotive/features/main_app/domain/entities/app_data.dart";

abstract class AppDataFirestoreDataSource {
  Future<AppData?> getAppData();
  Future<void> updateAppData(AppData appData);
  Future<void> deleteAppData();
}

class AppDataFirestoreDataSourceImpl implements AppDataFirestoreDataSource {
  AppDataFirestoreDataSourceImpl({
    required this.firebaseAuthService,
    required this.firebaseFirestoreService,
  });

  static const COLLECTION_NAME = "user_data";
  static const APP_DATA_KEY = "data";

  final FirebaseFirestore firebaseFirestoreService;
  final FirebaseAuth firebaseAuthService;
  late final CollectionReference userData =
      firebaseFirestoreService.collection(COLLECTION_NAME);

  @override
  Future<AppData?> getAppData() async {
    final uid = firebaseAuthService.currentUser!.uid;
    final data = await userData.doc(uid).get();
    if (!data.exists ||
        (data.data() as Map<String, dynamic>?)?[APP_DATA_KEY] == null) {
      return null;
    }
    return AppData.fromJson(
      json.decode(
        (data.data() as Map<String, dynamic>?)![APP_DATA_KEY] as String,
      ) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> updateAppData(AppData appData) async {
    final uid = firebaseAuthService.currentUser!.uid;
    final data = AppData(
      trains: appData.trains,
      freightCars: appData.freightCars,
      source: AppDataSource.server,
    );
    final jsonData = json.encode(data.toJson());
    await userData.doc(uid).set({APP_DATA_KEY: jsonData});
  }

  @override
  Future<void> deleteAppData() async {
    final uid = firebaseAuthService.currentUser!.uid;
    await userData.doc(uid).delete();
  }
}
