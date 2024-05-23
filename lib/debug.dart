import 'package:flutter/material.dart';
import 'package:mexanyd_desktop/sidemenu.dart';
import 'package:mexanyd_desktop/vehicle/base.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  String _debugData = "Debug data";

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      title: "Debug",
      icon: Icons.bug_report,
      actions: SideMenu(context).disableDebug(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          child: Column(
            children: [
              Text(
                _debugData,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  VehicleBase.showSelectDialog(context).then((value) {
                    if (value != null) {
                      setState(() {
                        _debugData =
                            "${value.brand} ${value.model} ${value.variant}";
                      });
                    }
                  });
                },
                child: const Text("Select Vehicle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
