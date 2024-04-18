import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/database/local.dart';
import 'package:mexanyd_desktop/inout/input.dart';
import 'package:mexanyd_desktop/inout/list.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  await findSystemLocale();
  initializeDateFormatting(Intl.systemLocale);

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

  String? error;
  if (database == "local") {
    prefs.setString("database", "local");
    final databaseVersion =
        prefs.getInt("database_version") ?? LocalDatabase.version;

    if (databaseVersion == LocalDatabase.version) {
      prefs.setInt("database_version", LocalDatabase.version);
      globalDatabase = await LocalDatabase.open();
    } else {
      error = "Versão do banco de dados inválida";
    }
  } else {
    error = "Banco de dados inválido";
  }

  runApp(MainApp(theme, error: error));
}

class MainApp extends StatelessWidget {
  final ThemeMode theme;
  final String? error;

  const MainApp(this.theme, {super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: darkTheme(),
      theme: lightTheme(),
      themeMode: theme,
      onGenerateRoute: (error == null) ? _pageRoute : null,
      home: (error == null) ? null : _errorPage(context, error!),
    );
  }

  PageRouteBuilder _pageRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/inout/list':
        return _pageRouteBuilder(const InOutListPage());
      default:
        return _pageRouteBuilder(const InOutInputPage());
    }
  }

  PageRouteBuilder _pageRouteBuilder(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  Widget _errorPage(BuildContext context, String message) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 128, color: Colors.red),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
    );
  }
}
