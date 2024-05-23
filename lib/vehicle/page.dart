import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/sidemenu.dart';
import 'package:mexanyd_desktop/vehicle/base.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      title: AppLocalizations.of(context)!.vehicle,
      icon: Icons.directions_car_rounded,
      actions: SideMenu(context).disableVehicle(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          child: const VehicleBase(),
        ),
      ),
    );
  }
}
