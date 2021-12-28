import "dart:convert";

import "package:locomotive/features/main_app/domain/entities/app_data.dart";
import "package:shared_preferences/shared_preferences.dart";

abstract class AppDataLocalDataSource {
  Future<AppData?> getAppData();
  Future<void> updateAppData(AppData appData);
  Future<void> deleteAppData();
}

class AppDataLocalDataSourceImpl implements AppDataLocalDataSource {
  AppDataLocalDataSourceImpl({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  static const APP_DATA_KEY = "AppData";

  @override
  Future<AppData?> getAppData() async {
    final jsonData = sharedPreferences.getString(APP_DATA_KEY);
    if (jsonData == null) return null;
    return AppData.fromJson(json.decode(jsonData) as Map<String, dynamic>);
  }

  @override
  Future<void> updateAppData(AppData appData) async {
    final data = AppData(
      trains: appData.trains,
      freightCars: appData.freightCars,
      source: AppDataSource.local,
    );
    final jsonData = json.encode(data.toJson());
    await sharedPreferences.setString(APP_DATA_KEY, jsonData);
  }

  @override
  Future<void> deleteAppData() async {
    await sharedPreferences.remove(APP_DATA_KEY);
  }
}
