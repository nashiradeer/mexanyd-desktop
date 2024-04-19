import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/inout/base.dart';
import 'package:mexanyd_desktop/widgets/buttons.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class InOutInputPage extends StatefulWidget {
  const InOutInputPage({super.key});

  @override
  State<InOutInputPage> createState() => _InOutInputState();
}

class _InOutInputState extends State<InOutInputPage> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final InOutController _inOutController = InOutController.fromDateTimeNow();
  final MexanydRadioController _mexanydRadioController =
      MexanydRadioController();
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return MexanydPage(
      title: "Entrada/Saída",
      icon: Icons.swap_vert_rounded,
      actions: [
        const MexanydPageButton(
          text1: "Entrada",
          text2: "Saída",
          icon: Icons.swap_vert_rounded,
          onPressed: null,
        ),
        const SizedBox(height: 5),
        MexanydPageButton(
          text1: "Listar",
          icon: Icons.list_alt_rounded,
          onPressed: () => Navigator.popAndPushNamed(context, "/inout/list"),
        ),
      ],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          child: Column(
            children: [
              MexanydIconRadio(
                icons: const [
                  Icons.money_rounded,
                  Icons.credit_card_rounded,
                  Icons.alarm_rounded,
                ],
                controller: _mexanydRadioController,
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
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Valor",
                        counterText: "",
                        errorText: _error ? "Inválido" : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: "Descrição",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: MexanydIconButton(
                      borderRadius: 15,
                      size: 40,
                      data: [
                        MexanydIconButtonData(
                          icon: Icons.add_rounded,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            _save();
                          },
                        ),
                        MexanydIconButtonData(
                          icon: Icons.remove_rounded,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            _save(invert: true);
                          },
                        ),
                      ],
                    ),
                  ),
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
