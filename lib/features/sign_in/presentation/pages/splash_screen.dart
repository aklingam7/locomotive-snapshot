import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.appName_I,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    AppLocalizations.of(context)!.appTagline_I,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 7,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
