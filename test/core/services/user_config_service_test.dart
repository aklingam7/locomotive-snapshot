import "package:flutter_test/flutter_test.dart";
import "package:locomotive/core/services/user_config_service.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:shared_preferences/shared_preferences.dart";

import "user_config_service_test.mocks.dart";

@GenerateMocks([SharedPreferences, UserConfigService])
void main() {
  MockSharedPreferences mockSharedPreferences = MockSharedPreferences();
  UserConfigService userConfigService = MockUserConfigService();

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    when(mockSharedPreferences.getString("locale")).thenReturn(null);
    when(mockSharedPreferences.getDouble("hoursPerCoal")).thenReturn(null);
    userConfigService = UserConfigServiceImpl(mockSharedPreferences);
    verify(mockSharedPreferences.getString("locale")).called(1);
    verify(mockSharedPreferences.getDouble("hoursPerCoal")).called(1);
    verifyNoMoreInteractions(mockSharedPreferences);
  });

  group("locale", () {
    test("should return valid locale when it exists", () {
      // arrange
      when(mockSharedPreferences.getString("locale")).thenReturn("ar");
      // act
      userConfigService = UserConfigServiceImpl(mockSharedPreferences);
      // assert
      verify(mockSharedPreferences.getString("locale")).called(1);
      expect(userConfigService.locale, "ar");
    });
    test("should return null when locale does not exist", () {
      // arrange
      when(mockSharedPreferences.getString("locale")).thenReturn(null);
      // act
      userConfigService = UserConfigServiceImpl(mockSharedPreferences);
      // assert
      verify(mockSharedPreferences.getString("locale")).called(1);
      expect(userConfigService.locale, null);
    });
  });
  group("setLocale", () {
    test("should successfully set locale", () async {
      // arrange
      when(mockSharedPreferences.setString("locale", "es"))
          .thenAnswer((_) async => true);
      // act
      await userConfigService.setLocale("es");
      // assert
      verify(mockSharedPreferences.setString("locale", "es")).called(1);
      verifyNoMoreInteractions(mockSharedPreferences);
      expect(userConfigService.locale, "es");
    });
  });
}
