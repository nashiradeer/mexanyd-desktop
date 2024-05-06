import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/main.dart';
import 'package:mexanyd_desktop/sidemenu.dart';
import 'package:mexanyd_desktop/widgets/buttons.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class ConfigurationPage extends StatelessWidget {
  const ConfigurationPage({super.key});

  int _themeIndex(ThemeMode? theme) {
    switch (theme) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      icon: Icons.settings_rounded,
      title: AppLocalizations.of(context)!.fullConfig,
      actions: SideMenu(context).disableConfig(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: MexanydIconRadio(
                  size: 25,
                  icons: const [
                    Icons.desktop_windows_rounded,
                    Icons.light_mode_rounded,
                    Icons.dark_mode_rounded,
                  ],
                  selectedIndex: _themeIndex(appController.theme),
                  onChanged: (index) {
                    switch (index) {
                      case 0:
                        appController.setTheme(ThemeMode.system);
                        break;
                      case 1:
                        appController.setTheme(ThemeMode.light);
                        break;
                      case 2:
                        appController.setTheme(ThemeMode.dark);
                        break;
                    }
                  },
                ),
              ),
              const SizedBox(height: 60),
              Text(AppLocalizations.of(context)!.language,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton(
                  items: const [
                    DropdownMenuItem(
                      value: "en",
                      child: Text("English"),
                    ),
                    DropdownMenuItem(
                      value: "pt",
                      child: Text("Português"),
                    ),
                  ],
                  onChanged: (value) {
                    appController
                        .setLocale((value != null) ? Locale(value) : null);
                  },
                  value: appController.locale?.languageCode,
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  underline: Container(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
