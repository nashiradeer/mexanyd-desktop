import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class SideMenu {
  final List<Widget> _items;

  SideMenu._(this._items);

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
      const Spacer(),
      MexanydPageButton(
        text1: AppLocalizations.of(context)!.config,
        icon: Icons.settings_rounded,
        onPressed: () => Navigator.popAndPushNamed(context, "/config"),
      ),
    ]);
  }

  List<Widget> get items => _items;

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

  List<Widget> disableInOut() {
    return _buildSideMenu(0);
  }

  List<Widget> disableList() {
    return _buildSideMenu(2);
  }

  List<Widget> disableConfig() {
    return _buildSideMenu(_items.length - 1);
  }
}
