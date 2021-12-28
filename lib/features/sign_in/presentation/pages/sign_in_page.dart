import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:locomotive/core/errors/failures.dart";
import "package:locomotive/core/widgets/alert_dialog.dart";
import "package:locomotive/features/sign_in/presentation/bloc/auth_bloc.dart";
import "package:locomotive/features/sign_in/presentation/pages/onboarding_screen.dart";
import "package:locomotive/features/sign_in/presentation/pages/sign_in_screen.dart";
import "package:locomotive/features/sign_in/presentation/pages/splash_screen.dart";
import "package:locomotive/services.dart";

class SignInPage extends StatefulWidget {
  const SignInPage({required this.goToMainPage, Key? key}) : super(key: key);

  final void Function() goToMainPage;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthBloc authBloc = AuthBloc(
    uGetAuthState: sl(),
    uSignInWithEmail: sl(),
    uSignUpWithEmail: sl(),
    uSignInWithGoogle: sl(),
  );

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(const Duration(milliseconds: 2000));
      authBloc.add(GetAuthData());
    }();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: authBloc,
      builder: (_, state) => state.runtimeType == ShowSplashScreen
          ? const SplashScreen()
          : AbsorbPointer(
              absorbing: state.runtimeType == Loading,
              child: SignInScreen(authBloc: authBloc),
            ),
      listener: (context, state) {
        switch (state.runtimeType) {
          case GoToApp:
            widget.goToMainPage();
            break;
          case NoUser:
            _showOnboarding(context);
            break;
          case VerificationNeeded:
            _showVerificationNeeded(context);
            break;
          case NoInternetConnection:
            _showNoInternet(context);
            break;
          case AuthenticationError:
            state as AuthenticationError;
            _showAuthError(context, issue: state.issue);
            break;
          case UnexpectedError:
            state as UnexpectedError;
            _showError(context, body: state.message);
            break;
          default:
            break;
        }
      },
    );
  }

  void _showOnboarding(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialogW(
        title: AppLocalizations.of(context)!.onboardingScreen_T,
        content: const OnboardingScreen(),
      ),
    );
  }

  void _showVerificationNeeded(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialogW(
        title: AppLocalizations.of(context)!.needVerificationError_T,
        body: AppLocalizations.of(context)!.needVerificationErrorBody_ML,
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok_BL),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showNoInternet(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialogW(
        title: AppLocalizations.of(context)!.noInternetError_T,
        body: AppLocalizations.of(context)!.noInternetErrorBody_ML,
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok_BL),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showAuthError(
    BuildContext context, {
    required UserCreationIssue issue,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialogW(
        title: AppLocalizations.of(context)!.userCreationError_T,
        body: AppLocalizations.of(context)!.userCreationErrorBody_ML,
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok_BL),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showError(
    BuildContext context, {
    String? title,
    String? body,
  }) {
    title ??= AppLocalizations.of(context)!.defaultError_T;
    body ??= AppLocalizations.of(context)!.defaultErrorBody_ML;

    showDialog(
      context: context,
      builder: (_) => AlertDialogW(
        title: title!,
        body: body,
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok_BL),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
