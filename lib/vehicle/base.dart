import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:mexanyd_desktop/widgets/buttons.dart';
import 'package:mexanyd_desktop/widgets/paginator.dart';

class VehicleBase extends StatefulWidget {
  final void Function(BuildContext, Vehicle)? onSelect;

  const VehicleBase({super.key, this.onSelect});

  /// Selects a vehicle from a dialog.
  static Future<Vehicle?> showSelectDialog(BuildContext context) {
    return showDialog<Vehicle>(
      context: context,
      builder: (context) {
        return selectDialog(context, (context, vehicle) {
          Navigator.pop(context, vehicle);
        });
      },
    );
  }

  static Widget selectDialog(
      BuildContext context, void Function(BuildContext, Vehicle) onSelect) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(10),
        child: VehicleBase(
          onSelect: onSelect,
        ),
      ),
    );
  }

  @override
  State<VehicleBase> createState() => _VehicleState();
}

class _VehicleState extends State<VehicleBase> {
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController variantController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              flex: 1,
              child: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z 0-9]'))
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
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z 0-9,\.]'))
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
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z 0-9,\.]'))
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
          itemBuilder: (context, vehicle) => _VehicleItem(
            vehicle: vehicle,
            buttonIcon: widget.onSelect != null
                ? const Icon(
                    Icons.play_arrow_rounded,
                  )
                : const Icon(Icons.delete_rounded),
            onClick: widget.onSelect != null
                ? (selection) => widget.onSelect!(context, selection)
                : _delete,
          ),
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
        .then((_) {
      brandController.clear();
      modelController.clear();
      variantController.clear();
      setState(() {});
    });
  }

  void _delete(Vehicle vehicle) {
    globalDatabase.deleteVehicle(vehicle.id).then((_) {
      setState(() {});
    });
  }
}

class _VehicleItem extends StatelessWidget {
  final Vehicle vehicle;
  final Icon buttonIcon;
  final void Function(Vehicle) onClick;

  const _VehicleItem({
    required this.vehicle,
    required this.buttonIcon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20, bottom: 5, top: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          icon: buttonIcon,
          onPressed: () => onClick(vehicle),
        ),
      ),
    );
  }
}
