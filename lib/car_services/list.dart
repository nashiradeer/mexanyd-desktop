import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/sidemenu.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:mexanyd_desktop/vehicle/base.dart';
import 'package:mexanyd_desktop/widgets/buttons.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class CarServicesList extends StatefulWidget {
  const CarServicesList({super.key});

  @override
  State<CarServicesList> createState() => _CarServicesListState();
}

class _CarServicesListState extends State<CarServicesList> {
  Vehicle? _vehicle;
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      title: AppLocalizations.of(context)!.services,
      icon: Icons.home_repair_service_rounded,
      actions: SideMenu(context).disableServices(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 47,
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            VehicleBase.showSelectDialog(context).then((value) {
                              if (value != null) {
                                setState(() {
                                  _vehicle = value;
                                });
                              }
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.primary),
                            foregroundColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.onPrimary),
                            shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  bottomLeft: Radius.circular(18),
                                ),
                              ),
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            fixedSize: const WidgetStatePropertyAll(
                                Size(double.infinity, 50)),
                          ),
                          child: _vehicleText(context),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _vehicle = null;
                          }),
                          style: ButtonStyle(
                            backgroundColor:
                                const WidgetStatePropertyAll(Colors.red),
                            foregroundColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.onPrimary),
                            shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                ),
                              ),
                            ),
                            padding: const WidgetStatePropertyAll(
                                EdgeInsets.only(right: 5)),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            iconSize: const WidgetStatePropertyAll(18),
                            fixedSize: const WidgetStatePropertyAll(
                                Size(double.infinity, 50)),
                          ),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _plateController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9A-Za-z\-]')),
                      ],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.plate,
                        border: textFieldBorder(context),
                      ),
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();
                        _reload();
                      },
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();
                        _reload();
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      controller: _ownerController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
                      ],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.owner,
                        border: textFieldBorder(context),
                      ),
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();
                        _reload();
                      },
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();
                        _reload();
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  MexanydIconButton.fixedWidth(
                    [
                      MexanydIconButtonData(
                        icon: Icons.search_rounded,
                        onPressed: _reload,
                      ),
                      MexanydIconButtonData(
                        icon: Icons.add_rounded,
                        backgroundColor: Colors.green,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reload() {
    setState(() {
      _plateController.text = _plateController.text.toUpperCase();
    });
  }

  Text _vehicleText(BuildContext context) {
    if (_vehicle == null) {
      return Text(AppLocalizations.of(context)!.selectVehicle);
    }

    return Text("${_vehicle!.brand} ${_vehicle!.model} ${_vehicle!.variant}");
  }
}
