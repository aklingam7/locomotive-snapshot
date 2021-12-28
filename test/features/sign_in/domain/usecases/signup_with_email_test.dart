import "package:flutter_test/flutter_test.dart";
import "package:locomotive/features/sign_in/domain/repositories/authentication_repository.dart";
import "package:locomotive/features/sign_in/domain/usecases/signup_with_email.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "signup_with_email_test.mocks.dart";

@GenerateMocks([AuthenticationRepository])
void main() {
  final mockAuthenticationRepository = MockAuthenticationRepository();
  final usecase = USignUpWithEmail(mockAuthenticationRepository);

  test("should call authenticateWithEmail from the repository", () async {
    // arrange
    when(
      mockAuthenticationRepository.signUpWithEmail(
        displayName: "A. P.",
        email: "abc@xyz.com",
        password: "pass",
      ),
    ).thenAnswer(
      (_) async => null,
    );
    // act
    final userData = await usecase(
      displayName: "A. P.",
      email: "abc@xyz.com",
      password: "pass",
    );
    // assert
    verify(
      mockAuthenticationRepository.signUpWithEmail(
        displayName: "A. P.",
        email: "abc@xyz.com",
        password: "pass",
      ),
    ).called(1);
    verifyNoMoreInteractions(mockAuthenticationRepository);
    expect(userData, null);
  });
}
