import 'package:flutter/material.dart';
import 'package:mexanyd_desktop/in_out_input.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions options = const WindowOptions(
    title: 'Mexanyd Desktop',
    minimumSize: Size(400, 600),
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
      home: const InOutInput(),
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
    );
  }
}
