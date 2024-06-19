import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/theme.dart';
import 'package:mexanyd_desktop/widgets/buttons.dart';
import 'package:mexanyd_desktop/widgets/paginator.dart';

/// A base class for vehicle selection.
class VehicleBase extends StatefulWidget {
  /// The function to call when a vehicle is selected. If null, the delete button is shown.
  final void Function(BuildContext, Vehicle)? onSelect;

  /// Creates a new vehicle base.
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

  /// Creates a dialog for selecting a vehicle.
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

/// The state of the vehicle base.
class _VehicleState extends State<VehicleBase> {
  /// The controller for the brand text field.
  final TextEditingController _brandController = TextEditingController();

  /// The controller for the model text field.
  final TextEditingController _modelController = TextEditingController();

  /// The controller for the variant text field.
  final TextEditingController _variantController = TextEditingController();

  bool _brandError = false;
  bool _modelError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z 0-9]'))
                ],
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.brand,
                  border: textFieldBorder(context),
                  errorText: _brandError
                      ? AppLocalizations.of(context)!.requiredField
                      : null,
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
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.model,
                  border: textFieldBorder(context),
                  errorText: _modelError
                      ? AppLocalizations.of(context)!.requiredField
                      : null,
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
                controller: _variantController,
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
            MexanydIconButton.fixedWidth(
              [
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
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 5),
        Paginator(
          itemBuilder: (context, vehicleData) => _VehicleItem(
            vehicle: vehicleData.vehicle,
            buttonIcon: _generateItemIcon(vehicleData.canDelete),
            onClick: widget.onSelect != null
                ? (selection) => widget.onSelect!(context, selection)
                : _delete,
          ),
          fetcher: (params) async {
            final vehicles = await globalDatabase.listVehicle(
              limit: params.pageSize,
              offset: params.offset,
              brand: _brandController.text,
              model: _modelController.text,
              variant: _variantController.text,
            );

            var vehiclesData = [];
            for (var vehicle in vehicles) {
              vehiclesData.add(_VehicleData(
                vehicle,
                widget.onSelect != null
                    ? false
                    : await globalDatabase.hasServiceWithVehicle(vehicle.id),
              ));
            }

            return vehiclesData;
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

  /// Reloads the vehicle list.
  void _reload() {
    setState(() {
      _brandError = false;
      _modelError = false;
    });
  }

  /// Adds a new vehicle from the text fields.
  void _add() {
    final brand = _brandController.text;
    final model = _modelController.text;
    final variant = _variantController.text;

    if (brand.isEmpty || model.isEmpty) {
      setState(() {
        _brandError = brand.isEmpty;
        _modelError = model.isEmpty;
      });
      return;
    }

    globalDatabase.insertVehicle(brand, model, variant).then((_) {
      setState(() {
        _brandController.clear();
        _modelController.clear();
        _variantController.clear();

        _brandError = false;
        _modelError = false;
      });
    });
  }

  /// Deletes a vehicle using its ID.
  void _delete(Vehicle vehicle) {
    globalDatabase.deleteVehicle(vehicle.id).then((_) => _reload());
  }

  /// Generates the icon for a vehicle item.
  Icon? _generateItemIcon(bool canDelete) {
    if (widget.onSelect != null) {
      return const Icon(Icons.play_arrow_rounded);
    }

    if (canDelete) {
      return const Icon(Icons.delete_rounded);
    }

    return null;
  }
}

/// A widget that displays a single vehicle.
class _VehicleItem extends StatelessWidget {
  /// The vehicle to display.
  final Vehicle vehicle;

  /// The icon to display on the button.
  final Icon? buttonIcon;

  /// The function to call when the button is clicked.
  final void Function(Vehicle) onClick;

  /// Creates a new vehicle item.
  const _VehicleItem({
    required this.vehicle,
    this.buttonIcon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 5, top: 5),
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
        trailing: buttonIcon == null
            ? null
            : IconButton(
                icon: buttonIcon!,
                onPressed: () => onClick(vehicle),
              ),
      ),
    );
  }
}

/// The data for a vehicle item.
class _VehicleData {
  /// The vehicle to display.
  final Vehicle vehicle;

  /// Whether the vehicle can be deleted.
  final bool canDelete;

  /// Creates a new vehicle data.
  const _VehicleData(this.vehicle, this.canDelete);
}
