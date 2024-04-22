import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:intl/locale.dart' as intl_locale;
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/database/local.dart';
import 'package:mexanyd_desktop/inout/input.dart';
import 'package:mexanyd_desktop/inout/list.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:mexanyd_desktop/widgets/page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

late final AppController appController;

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

  final locale = prefs.getString("locale") ?? await findSystemLocale();
  Intl.defaultLocale = locale;
  await initializeDateFormatting(locale);
  prefs.setString("locale", locale);

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

  String? error;
  final database = prefs.getString("database") ?? "local";
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

  final parsedLocale = intl_locale.Locale.tryParse(locale);

  appController = AppController(
    theme: theme,
    locale: parsedLocale != null
        ? Locale(parsedLocale.languageCode, parsedLocale.countryCode)
        : null,
    error: error,
  );

  runApp(App(appController));
}

class AppController extends ChangeNotifier {
  ThemeMode? _theme;
  Locale? _locale;
  String? _error;

  ThemeMode? get theme => _theme;
  Locale? get locale => _locale;
  String? get error => _error;

  AppController({ThemeMode? theme, Locale? locale, String? error})
      : _theme = theme,
        _locale = locale,
        _error = error;

  void setTheme(ThemeMode? theme) {
    _theme = theme;
    notifyListeners();
  }

  void setLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

class App extends StatefulWidget {
  final AppController controller;

  const App(this.controller, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: darkTheme(),
      theme: lightTheme(),
      themeMode: widget.controller._theme ?? ThemeMode.system,
      onGenerateRoute: (widget.controller._error == null) ? _pageRoute : null,
      home: (widget.controller._error == null)
          ? null
          : _errorPage(context, widget.controller._error!),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt'),
        Locale('en'),
      ],
      locale: widget.controller._locale,
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
    return MexanydPage(
      icon: Icons.error,
      title: 'Erro',
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
