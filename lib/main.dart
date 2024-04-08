import 'package:flutter/material.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/database/local.dart';
import 'package:mexanyd_desktop/inout/input.dart';
import 'package:mexanyd_desktop/inout/list.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  globalDatabase = await LocalDatabase.open();

  var options = const WindowOptions(
    title: 'Mexanyd Desktop',
    minimumSize: Size(600, 800),
    size: Size(600, 800),
    center: true,
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
      initialRoute: '/inout',
      routes: {
        '/inout': (context) => const InOutInputPage(),
        '/inout/list': (context) => const InOutListPage(),
      },
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}
