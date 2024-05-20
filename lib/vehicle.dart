import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/sidemenu.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehicleState();
}

class _VehicleState extends State<VehiclePage> {
  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      title: AppLocalizations.of(context)!.vehicle,
      icon: Icons.directions_car_rounded,
      actions: SideMenu(context).disableVehicle(),
      child: const Center(
        child: Text('Vehicle page'),
      ),
    );
  }
}
