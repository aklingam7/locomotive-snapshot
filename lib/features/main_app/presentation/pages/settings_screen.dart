import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:locomotive/core/services/user_config_service.dart";
import "package:locomotive/core/widgets/alert_dialog.dart";
import "package:locomotive/core/widgets/text_field.dart";
import "package:locomotive/features/main_app/domain/entities/user_profile.dart";
import "package:locomotive/features/main_app/presentation/bloc/main_app_bloc.dart";
import "package:locomotive/services.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen(this.userProfile, {required this.bloc, Key? key})
      : super(key: key);

  final UserProfile userProfile;
  final MainAppBloc bloc;

  static const profileImages = [
    "assets/images/bear.jpg",
    "assets/images/cat.jpg",
    "assets/images/hamster.jpg",
    "assets/images/sheep.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialogW(
      title: AppLocalizations.of(context)!.settingsScreen_T,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Scrollbar(
          child: ListView(
            shrinkWrap: true,
            children: [
              Card(
                elevation: 3,
                color: Theme.of(context).colorScheme.secondary,
                child: SizedBox(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          foregroundImage: AssetImage(
                            profileImages[userProfile.name.hashCode % 4],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile.name,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Text(
                              AppLocalizations.of(context)!.createdOn_MS(
                                "${userProfile.creationTime.day}/${userProfile.creationTime.month}/${userProfile.creationTime.year}",
                              ),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialogW(
                                  title: "Logout",
                                  body:
                                      "Are you sure you want to logout? Make sure you've synced your data before logging out.",
                                  actions: [
                                    TextButton(
                                      child: const Text(
                                        "Cancel",
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text(
                                        "Logout",
                                      ),
                                      onPressed: () {
                                        bloc.add(SignOutE());
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.language),
                      label: Text(AppLocalizations.of(context)!.setLang_BL),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            const locales = {
                              "English": "en",
                              "Español": "es",
                              "اَلْعَرَبِيَّةُ": "ar",
                              "తెలుగు": "te"
                            };
                            String dV = "English";
                            locales.forEach(
                              (k, v) {
                                if (v == sl<UserConfigService>().locale) dV = k;
                              },
                            );
                            return AlertDialogW(
                              title: "Set Language/Locale",
                              content: SizedBox(
                                width: 250,
                                height: 60,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    const Text(
                                      "Restart the app to see changes.",
                                    ),
                                    StatefulBuilder(
                                      builder: (context, setState) {
                                        return DropdownButton<String>(
                                          value: dV,
                                          icon:
                                              const Icon(Icons.arrow_downward),
                                          items: <String>[
                                            "English",
                                            "Español",
                                            "اَلْعَرَبِيَّةُ",
                                            "తెలుగు"
                                          ]
                                              .map(
                                                (e) => DropdownMenuItem<String>(
                                                  value: e,
                                                  child: Text(e),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            setState(() => dV = val!);
                                            try {
                                              if (kDebugMode) {
                                                print("$val ${locales[val]}");
                                              }
                                              sl<UserConfigService>()
                                                  .setLocale(locales[val]!);
                                            } catch (e, s) {
                                              if (kDebugMode) {
                                                print("$e \n$s");
                                              }
                                            }
                                          },
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.timelapse),
                      label: Text(AppLocalizations.of(context)!.setHrsPCoal_BL),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            final tC = TextEditingController();
                            return AlertDialogW(
                              title: "Set Hours per Coal",
                              content: SizedBox(
                                width: 250,
                                height: 80,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    TextFieldW(
                                      keyboardType: TextInputType.number,
                                      label: const Text("Hours per Coal"),
                                      controller: tC,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const Text(
                                      "Restart the app to see changes.",
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    try {
                                      sl<UserConfigService>().setHoursPerCoal(
                                        double.parse(tC.text),
                                      );
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialogW(
                                            title: "Error",
                                            content: const Text(
                                              "Invalid input. Please enter a number.",
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text(
                                                  "OK",
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.info),
                      label: Text(AppLocalizations.of(context)!.about_BL),
                      onPressed: () {
                        showAboutDialog(
                          context: context,
                          applicationName: "Locomotive",
                          applicationVersion: "0.1.0",
                          applicationIcon: Image.asset(
                            "assets/icon/icon.png",
                            width: 80,
                          ),
                          applicationLegalese:
                              "App Logo/Icon by Vecteezy: https://www.vecteezy.com/free-vector/train \nContact Us: tetram.gg@gmail.com \nCopyright © 2021 Aditya Lingam",
                        );
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.warning),
                      label: Text(AppLocalizations.of(context)!.deleteData_BL),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialogW(
                              title: "Are You Sure!",
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    bloc.add(DeleteAppDataE());
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Delete"),
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.ok_BL),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
