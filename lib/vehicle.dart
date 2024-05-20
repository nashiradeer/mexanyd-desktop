import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/sidemenu.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:mexanyd_desktop/widgets/buttons.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehicleState();
}

class _VehicleState extends State<VehiclePage> {
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController variantController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      title: AppLocalizations.of(context)!.vehicle,
      icon: Icons.directions_car_rounded,
      actions: SideMenu(context).disableVehicle(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z 0-9]'))
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.brand,
                    border: textFieldBorder(context),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z 0-9,\.]'))
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.model,
                    border: textFieldBorder(context),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z 0-9]'))
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.variant,
                    border: textFieldBorder(context),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              MexanydIconButton(
                data: [
                  MexanydIconButtonData(
                    icon: Icons.search_rounded,
                    onPressed: _search,
                  ),
                  MexanydIconButtonData(
                    icon: Icons.add_rounded,
                    onPressed: _add,
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void _search() {}

  @override
  void _add() {}
}
