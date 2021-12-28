import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:google_fonts/google_fonts.dart";
import "package:locomotive/core/services/user_config_service.dart";
import "package:locomotive/features/main_app/presentation/pages/main_app.dart";
import "package:locomotive/features/sign_in/presentation/pages/sign_in_page.dart";
import "package:locomotive/services.dart";

// ignore: avoid_void_async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices(useFireStoreEmulator: false);
  runApp(const RootWidget(child: LocomotiveApp()));
}

class RootWidget extends StatelessWidget {
  const RootWidget({required this.child, Key? key}) : super(key: key);

  final Widget child;

  Locale _localeListResolutionCallback(
    List<Locale>? locales,
    Iterable<Locale> supportedLocales,
  ) {
    String? configLocale;
    try {
      configLocale = sl<UserConfigService>().locale;
    } catch (_) {
      configLocale = null;
    }
    if (configLocale != null) {
      for (final locale in supportedLocales) {
        if (locale.languageCode == configLocale) return locale;
      }
    }
    if (locales == null) return const Locale("en", "");
    for (final locale in locales) {
      for (final supportedLocale in supportedLocales) {
        if (locale.languageCode == supportedLocale.languageCode) {
          return locale;
        }
      }
    }
    return const Locale("en", "");
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return MaterialApp(
      title: "Locomotive",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.brown,
          accentColor: Colors.blueGrey[300],
          cardColor: Colors.blueGrey[100],
        ),
        textTheme: GoogleFonts.ubuntuMonoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: _localeListResolutionCallback,
      debugShowCheckedModeBanner: false,
      home: child,
    );
  }
}

class LocomotiveApp extends StatefulWidget {
  const LocomotiveApp({Key? key}) : super(key: key);

  @override
  _LocomotiveAppState createState() => _LocomotiveAppState();
}

class _LocomotiveAppState extends State<LocomotiveApp> {
  late Widget _currentPage;

  void _goToMainApp() {
    setState(() {
      _currentPage = MainApp(goToSignInPage: _goToSignInPage);
    });
  }

  void _goToSignInPage() {
    setState(() {
      _currentPage = SignInPage(goToMainPage: _goToMainApp);
    });
  }

  @override
  void initState() {
    _currentPage = SignInPage(goToMainPage: _goToMainApp);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _currentPage;
  }
}
