import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/sidemenu.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:mexanyd_desktop/widgets/buttons.dart';
import 'package:mexanyd_desktop/widgets/page.dart';
import 'package:mexanyd_desktop/widgets/paginator.dart';

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
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z 0-9]'))
                      ],
                      controller: brandController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.brand,
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
                  Flexible(
                    flex: 3,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z 0-9,\.]'))
                      ],
                      controller: modelController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.model,
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
                  Flexible(
                    flex: 1,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z 0-9,\.]'))
                      ],
                      controller: variantController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.variant,
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
                  SizedBox(
                    width: 120,
                    child: MexanydIconButton(
                      borderRadius: 15,
                      size: 40,
                      data: [
                        MexanydIconButtonData(
                          icon: Icons.search_rounded,
                          onPressed: _reload,
                        ),
                        MexanydIconButtonData(
                          icon: Icons.add_rounded,
                          onPressed: _add,
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Paginator(
                itemBuilder: (context, vehicle) => _VehicleItem(vehicle, this),
                fetcher: (params) {
                  return globalDatabase.listVehicle(
                    limit: params.pageSize,
                    offset: params.offset,
                    brand: brandController.text,
                    model: modelController.text,
                    variant: variantController.text,
                  );
                },
                prefetch: (context) {
                  return globalDatabase
                      .countVehicle()
                      .then((value) => PaginatorPrefetchData(value));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reload() {
    setState(() {});
  }

  void _add() {
    globalDatabase
        .insertVehicle(
      brandController.text,
      modelController.text,
      variantController.text,
    )
        .then((value) {
      brandController.clear();
      modelController.clear();
      variantController.clear();
      setState(() {});
    });
  }

  void delete(int id) {
    globalDatabase.deleteVehicle(id).then((value) {
      setState(() {});
    });
  }
}

class _VehicleItem extends StatelessWidget {
  final Vehicle vehicle;
  final _VehicleState parent;

  const _VehicleItem(this.vehicle, this.parent);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20, bottom: 5, top: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${vehicle.brand} ${vehicle.model}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              vehicle.variant,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        leading: Icon(
          Icons.directions_car_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_rounded),
          onPressed: () => parent.delete(vehicle.id),
        ),
      ),
    );
  }
}
