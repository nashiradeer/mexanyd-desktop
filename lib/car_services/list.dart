import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/sidemenu.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class CarServicesList extends StatelessWidget {
  const CarServicesList({super.key});

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      title: AppLocalizations.of(context)!.services,
      icon: Icons.home_repair_service_rounded,
      actions: SideMenu(context).disableServices(),
      child: const Center(
        child: Text('Car Services List'),
      ),
    );
  }
}
