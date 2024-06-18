import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:intl/locale.dart' as intl_locale;
import 'package:mexanyd_desktop/car_services/list.dart';
import 'package:mexanyd_desktop/configuration.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/database/local.dart';
import 'package:mexanyd_desktop/debug.dart';
import 'package:mexanyd_desktop/inout/input.dart';
import 'package:mexanyd_desktop/inout/list.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:mexanyd_desktop/vehicle/page.dart';
import 'package:mexanyd_desktop/widgets/page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

late AppController appController;

/// Application entry point.
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

  int? error;
  final database = prefs.getString("database") ?? "local";
  if (database == "local") {
    prefs.setString("database", "local");
    final databaseVersion =
        prefs.getInt("database_version") ?? LocalDatabase.version;

    if (databaseVersion == LocalDatabase.version) {
      prefs.setInt("database_version", LocalDatabase.version);
      globalDatabase = await LocalDatabase.open();
    } else {
      error = 0;
    }
  } else {
    error = 1;
  }

  final parsedLocale = intl_locale.Locale.tryParse(locale);

  appController = AppController(
    theme: theme,
    locale: parsedLocale != null
        ? Locale.fromSubtags(
            languageCode: parsedLocale.languageCode,
            scriptCode: parsedLocale.scriptCode,
            countryCode: parsedLocale.countryCode,
          )
        : null,
    error: error,
  );

  runApp(App(appController));
}

/// Controller for the application.
class AppController extends ChangeNotifier {
  /// The theme mode of the application.
  ThemeMode? _theme;

  /// The locale of the application.
  Locale? _locale;

  /// The error code of the application.
  int? _error;

  /// Gets the theme mode of the application.
  ThemeMode? get theme => _theme;

  /// Gets the locale of the application.
  Locale? get locale => _locale;

  /// Gets the error code of the application.
  int? get error => _error;

  /// Creates a new [AppController].
  AppController({ThemeMode? theme, Locale? locale, int? error})
      : _theme = theme,
        _locale = locale,
        _error = error;

  /// Sets the theme mode of the application.
  void setTheme(ThemeMode? theme) {
    _theme = theme;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("theme", _themeToString(theme));
    });
    notifyListeners();
  }

  /// Converts a [ThemeMode] to a string.
  String _themeToString(ThemeMode? theme) {
    switch (theme) {
      case ThemeMode.dark:
        return "dark";
      case ThemeMode.light:
        return "light";
      default:
        return "system";
    }
  }

  /// Sets the locale of the application.
  void setLocale(Locale? locale) {
    _locale = locale;

    if (locale != null) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString("locale", locale.toLanguageTag());
      });
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove("locale");
      });
    }

    notifyListeners();
  }

  /// Sets the error code of the application.
  void setError(int? error) {
    _error = error;
    notifyListeners();
  }
}

/// The application widget.
class App extends StatefulWidget {
  /// The controller of the application.
  final AppController controller;

  /// Creates a new [App].
  const App(this.controller, {super.key});

  @override
  State<App> createState() => _AppState();
}

/// State of the [App].
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
          : ErrorPage(widget.controller._error!),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: widget.controller._locale,
    );
  }

  /// Generates a route based on the settings.
  PageRouteBuilder _pageRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/inout/list':
        return _pageRouteBuilder(const InOutListPage());
      case '/config':
        return _pageRouteBuilder(const ConfigurationPage());
      case '/services':
        return _pageRouteBuilder(const CarServicesList());
      case '/vehicle':
        return _pageRouteBuilder(const VehiclePage());
      case '/debug':
        return _pageRouteBuilder(const DebugPage());
      default:
        return _pageRouteBuilder(const InOutInputPage());
    }
  }

  /// Creates a page route builder, removing the transition.
  PageRouteBuilder _pageRouteBuilder(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}

/// A page that shows an error message.
class ErrorPage extends StatelessWidget {
  /// The error code.
  final int code;

  /// Creates a new [ErrorPage].
  const ErrorPage(this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      icon: Icons.error,
      title: AppLocalizations.of(context)!.error,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 128, color: Colors.red),
            const SizedBox(height: 10),
            Text(
              _errorMessage(code, context),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => exit(1),
              style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(Colors.red),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onPrimary),
                fixedSize: const WidgetStatePropertyAll(Size(200, 55)),
              ),
              child: Text(
                AppLocalizations.of(context)!.close,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the error message based on the error code.
  String _errorMessage(int code, BuildContext context) {
    switch (code) {
      case 0:
        return AppLocalizations.of(context)!.invalidDatabaseVersion;
      case 1:
        return AppLocalizations.of(context)!.invalidDatabase;
      default:
        return AppLocalizations.of(context)!.unknownError;
    }
  }
}
