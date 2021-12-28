import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_test/flutter_test.dart";
import "package:locomotive/core/services/connectivity_service.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "connectivity_service_test.mocks.dart";

@GenerateMocks([ConnectivityService, Connectivity])
void main() {
  MockConnectivity mockConnectivity = MockConnectivity();
  ConnectivityService connectivityService = MockConnectivityService();

  setUp(() {
    mockConnectivity = MockConnectivity();
    connectivityService =
        ConnectivityServiceImpl(connectivity: mockConnectivity);
  });

  group("networkAccessible", () {
    test("should return false when ConnectivityResult.none", () async {
      // arrange
      when(mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => ConnectivityResult.none,
      );
      // act
      final result = await connectivityService.networkAccessible;
      // assert
      expect(result, false);
      verify(mockConnectivity.checkConnectivity());
      verifyNoMoreInteractions(mockConnectivity);
    });

    test("should return true when ConnectivityResult.wifi", () async {
      // arrange
      when(mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => ConnectivityResult.wifi,
      );
      // act
      final result = await connectivityService.networkAccessible;
      // assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
      verifyNoMoreInteractions(mockConnectivity);
    });
  });
}
