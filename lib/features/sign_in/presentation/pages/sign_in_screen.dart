import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:locomotive/core/widgets/alert_dialog.dart";
import "package:locomotive/core/widgets/text_field.dart";
import "package:locomotive/features/sign_in/presentation/bloc/auth_bloc.dart";

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key, required this.authBloc}) : super(key: key);

  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/trains_bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(flex: 4, child: SignInPanel(authBloc: authBloc)),
            const Expanded(flex: 5, child: SizedBox())
          ],
        ),
      ],
    );
  }
}

class SignInPanel extends StatefulWidget {
  const SignInPanel({Key? key, required this.authBloc}) : super(key: key);

  final AuthBloc authBloc;

  @override
  _SignInPanelState createState() => _SignInPanelState();
}

class _SignInPanelState extends State<SignInPanel> {
  bool _signUp = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              AppLocalizations.of(context)!.appName_I,
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              AppLocalizations.of(context)!.appTagline_I,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            if (kIsWeb || !Platform.isIOS && !Platform.isMacOS) ...[
              Text(
                AppLocalizations.of(context)!.signInWithGoogle_T,
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 10),
              SignInWithGoogleButton(authBloc: widget.authBloc),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
            ],
            if (_signUp)
              EmailSignUpForm(
                authBloc: widget.authBloc,
                swap: () => setState(() => _signUp = false),
              )
            else
              EmailSignInForm(
                authBloc: widget.authBloc,
                swap: () => setState(() => _signUp = true),
              ),
          ],
        ),
      ),
    );
  }
}

class SignInWithGoogleButton extends StatelessWidget {
  const SignInWithGoogleButton({Key? key, required this.authBloc})
      : super(key: key);

  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const FaIcon(FontAwesomeIcons.google),
      label: const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Text("Sign In With Google"),
      ),
      onPressed: () => authBloc.add(SignInWithGoogle()),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Colors.red[300]!,
        ),
      ),
    );
  }
}

class EmailSignInForm extends StatefulWidget {
  const EmailSignInForm({
    Key? key,
    required this.authBloc,
    required this.swap,
  }) : super(key: key);

  final AuthBloc authBloc;
  final void Function() swap;

  @override
  State<EmailSignInForm> createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.signInWithEmail_T,
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(height: 10),
        TextFieldW(
          label: Text(AppLocalizations.of(context)!.emailLabel_MS),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        TextFieldW(
          label: Text(AppLocalizations.of(context)!.passwordLabel_MS),
          controller: _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: widget.swap,
          child: Text(AppLocalizations.of(context)!.createAccount_BL),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.account_circle),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text("Sign In"),
          ),
          onPressed: () {
            widget.authBloc.add(
              SignInWithEmail(
                email: _emailController.text,
                password: _passwordController.text,
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class EmailSignUpForm extends StatefulWidget {
  const EmailSignUpForm({
    Key? key,
    required this.authBloc,
    required this.swap,
  }) : super(key: key);

  final AuthBloc authBloc;
  final void Function() swap;

  @override
  State<EmailSignUpForm> createState() => _EmailSignUpFormState();
}

class _EmailSignUpFormState extends State<EmailSignUpForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.signUpWithEmail_T,
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(height: 10),
        TextFieldW(
          label: Text(AppLocalizations.of(context)!.nameLabel_MS),
          controller: _nameController,
        ),
        const SizedBox(height: 10),
        TextFieldW(
          label: Text(AppLocalizations.of(context)!.emailLabel_MS),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        TextFieldW(
          label: Text(AppLocalizations.of(context)!.passwordLabel_MS),
          controller: _passwordController,
          hintText: "10 or more characters",
          obscureText: true,
        ),
        const SizedBox(height: 10),
        TextFieldW(
          label:
              Text(AppLocalizations.of(context)!.passwordConfirmationLabel_MS),
          controller: _confirmPasswordController,
          obscureText: true,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: widget.swap,
          child: Text(AppLocalizations.of(context)!.signIn_BL),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.account_circle),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text("Create Account"),
          ),
          onPressed: () {
            if (_passwordController.text != _confirmPasswordController.text) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialogW(
                    title: "Passwords don't match",
                    content:
                        const Text("Please ensure that the passwords match."),
                    actions: [
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context)!.ok_BL,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  );
                },
              );
            } else {
              widget.authBloc.add(
                SignUpWithEmail(
                  displayName: _nameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                ),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
