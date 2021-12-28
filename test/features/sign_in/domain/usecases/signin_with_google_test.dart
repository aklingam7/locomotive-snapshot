import "package:flutter_test/flutter_test.dart";
import "package:locomotive/features/sign_in/domain/repositories/authentication_repository.dart";
import "package:locomotive/features/sign_in/domain/usecases/signin_with_google.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "signin_with_google_test.mocks.dart";

@GenerateMocks([AuthenticationRepository])
void main() {
  final mockAuthenticationRepository = MockAuthenticationRepository();
  final usecase = USignInWithGoogle(mockAuthenticationRepository);

  test("should call authenticateWithGoogle from the repository", () async {
    // arrange
    when(mockAuthenticationRepository.signInWithGoogle()).thenAnswer(
      (_) async => null,
    );
    // act
    final userData = await usecase();
    // assert
    verify(mockAuthenticationRepository.signInWithGoogle()).called(1);
    verifyNoMoreInteractions(mockAuthenticationRepository);
    expect(userData, null);
  });
}
