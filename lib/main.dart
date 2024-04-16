import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/database/local.dart';
import 'package:mexanyd_desktop/inout/input.dart';
import 'package:mexanyd_desktop/inout/list.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  var options = const WindowOptions(
    title: 'Mexanyd Desktop',
    minimumSize: Size(800, 600),
    size: Size(800, 600),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  var theme = ThemeMode.system;
  switch (prefs.getString("theme")) {
    case "dark":
      theme = ThemeMode.dark;
      break;
    case "light":
      theme = ThemeMode.light;
      break;
    default:
      prefs.setString("theme", "system");
  }

  final database = prefs.getString("database") ?? "local";

  if (database == "local") {
    prefs.setString("database", "local");
    final databaseVersion =
        prefs.getInt("database_version") ?? LocalDatabase.version;

    if (databaseVersion == LocalDatabase.version) {
      prefs.setInt("database_version", LocalDatabase.version);
      globalDatabase = await LocalDatabase.open();

      runApp(MainApp(theme));
    } else {
      runApp(ErrorApp(theme, "Versão do banco de dados inválida"));
    }
  }
}

class MainApp extends StatelessWidget {
  final ThemeMode theme;

  const MainApp(this.theme, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: darkTheme(),
      theme: lightTheme(),
      themeMode: theme,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/inout/list':
            return _pageRoute(const InOutListPage());
          default:
            return _pageRoute(const InOutInputPage());
        }
      },
    );
  }

  PageRouteBuilder _pageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  final ThemeMode theme;

  const ErrorApp(this.theme, this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: darkTheme(),
      theme: lightTheme(),
      themeMode: theme,
      home: Material(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 128, color: Colors.red),
              const SizedBox(height: 10),
              Text(
                message,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 80),
              TextButton(
                onPressed: () => exit(1),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  foregroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.onPrimary),
                  fixedSize: MaterialStateProperty.all(const Size(200, 55)),
                ),
                child: const Text('Fechar', style: TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
