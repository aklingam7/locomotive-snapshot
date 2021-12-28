import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

abstract class UserConfigService {
  String? get locale;
  Future<void> setLocale(String locale);

  double get hoursPerCoal;
  Future<void> setHoursPerCoal(double hours);
}

class UserConfigServiceImpl implements UserConfigService {
  UserConfigServiceImpl(this.sharedPreferences) {
    try {
      _locale = sharedPreferences.getString(_localeKey);
      _hoursPerCoal = sharedPreferences.getDouble(_hoursPerCoalKey) ?? 0.25;
    } catch (e, s) {
      if (kDebugMode) print("$e\n$s");
    }
  }

  static const String _localeKey = "locale";
  static const String _hoursPerCoalKey = "hoursPerCoal";

  final SharedPreferences sharedPreferences;

  String? _locale;
  @override
  String? get locale => _locale;
  @override
  Future<void> setLocale(String locale) async {
    try {
      await sharedPreferences.setString(_localeKey, locale);
    } finally {
      _locale = locale;
    }
  }

  double _hoursPerCoal = 0.25;
  @override
  double get hoursPerCoal => _hoursPerCoal;
  @override
  Future<void> setHoursPerCoal(double hours) async {
    try {
      await sharedPreferences.setDouble(_hoursPerCoalKey, hours);
    } finally {
      _hoursPerCoal = hours;
    }
  }
}
