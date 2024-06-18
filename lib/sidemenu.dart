import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

/// Utility class to create the side menu buttons.
class SideMenu {
  /// The list of items in the side menu.
  final List<Widget> _items;

  /// Creates a new side menu.
  SideMenu._(this._items);

  /// Creates a new side menu.
  factory SideMenu(BuildContext context) {
    return SideMenu._([
      MexanydPageButton(
        text1: AppLocalizations.of(context)!.inNoOut,
        text2: AppLocalizations.of(context)!.out,
        icon: Icons.swap_vert_rounded,
        onPressed: () => Navigator.popAndPushNamed(context, "/inout"),
      ),
      const SizedBox(height: 5),
      MexanydPageButton(
        text1: AppLocalizations.of(context)!.list,
        icon: Icons.list_alt_rounded,
        onPressed: () => Navigator.popAndPushNamed(context, "/inout/list"),
      ),
      const SizedBox(height: 5),
      MexanydPageButton(
        text1: AppLocalizations.of(context)!.services,
        icon: Icons.home_repair_service_rounded,
        onPressed: () => Navigator.popAndPushNamed(context, "/services"),
      ),
      const SizedBox(height: 5),
      MexanydPageButton(
        text1: AppLocalizations.of(context)!.vehicle,
        icon: Icons.directions_car_rounded,
        onPressed: () => Navigator.popAndPushNamed(context, "/vehicle"),
      ),
      const Spacer(),
      if (kDebugMode) ...[
        MexanydPageButton(
          text1: "Debug",
          icon: Icons.bug_report_rounded,
          onPressed: () => Navigator.popAndPushNamed(context, "/debug"),
        ),
        const SizedBox(height: 5),
      ],
      MexanydPageButton(
        text1: AppLocalizations.of(context)!.config,
        icon: Icons.settings_rounded,
        onPressed: () => Navigator.popAndPushNamed(context, "/config"),
      ),
    ]);
  }

  /// The list of items in the side menu.
  List<Widget> get items => _items;

  /// Builds the side menu with the selected item disabled.
  List<Widget> _buildSideMenu(int selectedIndex) {
    return List.generate(_items.length, (index) {
      if (_items[index] is MexanydPageButton && index == selectedIndex) {
        return MexanydPageButton.copyDisabled(
            _items[index] as MexanydPageButton);
      } else {
        return _items[index];
      }
    });
  }

  /// Disables the in/out button.
  List<Widget> disableInOut() {
    return _buildSideMenu(0);
  }

  /// Disables the list button.
  List<Widget> disableList() {
    return _buildSideMenu(2);
  }

  /// Disables the services button.
  List<Widget> disableServices() {
    return _buildSideMenu(4);
  }

  /// Disables the vehicle button.
  List<Widget> disableVehicle() {
    return _buildSideMenu(6);
  }

  /// Disables the configuration button.
  List<Widget> disableConfig() {
    return _buildSideMenu(_items.length - 1);
  }

  /// Disables the debug button.
  /// This method is only available in debug mode.
  List<Widget> disableDebug() {
    if (kDebugMode) {
      return _buildSideMenu(_items.length - 3);
    } else {
      return _items;
    }
  }
}
