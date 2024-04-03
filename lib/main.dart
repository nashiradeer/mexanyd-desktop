import 'package:flutter/material.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/database/local.dart';
import 'package:mexanyd_desktop/in_out_input.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  var database = await LocalDatabase.open();

  var options = const WindowOptions(
    title: 'Mexanyd Desktop',
    minimumSize: Size(400, 600),
  );

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MainApp(
    database,
  ));
}

class MainApp extends StatelessWidget {
  final IDatabase database;

  const MainApp(this.database, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InOutInput(database),
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
    );
  }
}
