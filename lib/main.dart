import 'package:flutter/material.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/database/local.dart';
import 'package:mexanyd_desktop/inout/input.dart';
import 'package:mexanyd_desktop/inout/list.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  globalDatabase = await LocalDatabase.open();

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

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: darkTheme(),
      theme: lightTheme(),
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
