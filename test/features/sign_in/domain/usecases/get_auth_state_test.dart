import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:locomotive/features/sign_in/domain/entities/user_data.dart";
import "package:locomotive/features/sign_in/domain/repositories/user_data_repository.dart";
import "package:locomotive/features/sign_in/domain/usecases/get_auth_state.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";

import "get_auth_state_test.mocks.dart";

@GenerateMocks([UserDataRepository])
void main() {
  final mockUserDataRepository = MockUserDataRepository();
  final usecase = UGetAuthState(mockUserDataRepository);

  test("should call getAuthState from the repository", () async {
    // arrange
    when(mockUserDataRepository.getAuthState()).thenAnswer(
      (_) async =>
          const Right(UserData(uid: null, emailVerificationNecessary: false)),
    );
    // act
    final userData = await usecase();
    // assert
    verify(mockUserDataRepository.getAuthState()).called(1);
    verifyNoMoreInteractions(mockUserDataRepository);
    expect(
      userData,
      const Right(UserData(uid: null, emailVerificationNecessary: false)),
    );
  });
}
