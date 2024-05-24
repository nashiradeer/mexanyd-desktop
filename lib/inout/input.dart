import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/inout/base.dart';
import 'package:mexanyd_desktop/sidemenu.dart';
import 'package:mexanyd_desktop/widgets/buttons.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

/// The page for inputting in/outs.
class InOutInputPage extends StatefulWidget {
  /// Creates a new in/out input page.
  const InOutInputPage({super.key});

  @override
  State<InOutInputPage> createState() => _InOutInputState();
}

/// The state of the in/out input page.
class _InOutInputState extends State<InOutInputPage> {
  /// The controller for the value text field.
  final TextEditingController _valueController = TextEditingController();

  /// The controller for the description text field.
  final TextEditingController _descriptionController = TextEditingController();

  /// The controller for the in/out list.
  final InOutController _inOutController = InOutController.fromDateTimeNow();

  /// The controller for the icon radio that selects the in/out type.
  final MexanydRadioController _mexanydRadioController =
      MexanydRadioController();

  /// The focus node for the value text field.
  final _valueFocus = FocusNode();

  /// Whether the value is invalid.
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      title: AppLocalizations.of(context)!.inOut,
      icon: Icons.swap_vert_rounded,
      actions: SideMenu(context).disableInOut(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: MexanydIconRadio(
                  icons: const [
                    Icons.money_rounded,
                    Icons.credit_card_rounded,
                    Icons.alarm_rounded,
                  ],
                  controller: _mexanydRadioController,
                ),
              ),
              const SizedBox(height: 10),
              // TextFields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _valueController,
                      focusNode: _valueFocus,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                        FilteringTextInputFormatter.deny(RegExp(r','),
                            replacementString: '.'),
                      ],
                      maxLength: 8,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.value,
                        counterText: "",
                        errorText: _error
                            ? AppLocalizations.of(context)!.invalid
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();

                        var value = double.tryParse(_valueController.text);
                        _error = value == null || value > 99999.99;
                        setState(() {});
                      },
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();

                        var value = double.tryParse(_valueController.text);
                        _error = value == null || value > 99999.99;
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.description,
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  MexanydIconButton.fixedWidth(
                    [
                      MexanydIconButtonData(
                        icon: Icons.add_rounded,
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          _save();
                          FocusScope.of(context).requestFocus(_valueFocus);
                        },
                      ),
                      MexanydIconButtonData(
                        icon: Icons.remove_rounded,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          _save(invert: true);
                          FocusScope.of(context).requestFocus(_valueFocus);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              // Today list
              InOutList(
                _inOutController,
                deleteButton: true,
                reversed: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Saves the in/out.
  void _save({bool invert = false}) {
    var value = double.tryParse(_valueController.text);

    if (value == null || value > 99999.99) {
      setState(() {
        _error = true;
      });

      return;
    }

    if (invert) {
      value = -value;
    }

    final type = InOutType.fromValue(_mexanydRadioController.selectedIndex);

    final String description = _descriptionController.text;

    globalDatabase.insertInOut(value, type, description: description);

    _valueController.clear();
    _descriptionController.clear();

    setState(() {
      _error = false;
    });
  }
}
