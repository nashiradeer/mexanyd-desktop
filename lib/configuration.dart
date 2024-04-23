import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class ConfigurationPage extends StatelessWidget {
  const ConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      icon: Icons.settings_rounded,
      title: AppLocalizations.of(context)!.fullConfig,
      actions: [
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
          onPressed: null,
        ),
      ],
      child: const Material(),
    );
  }
}
