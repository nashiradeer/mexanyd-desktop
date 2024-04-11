import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/inout/base.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class InOutInputPage extends StatefulWidget {
  const InOutInputPage({super.key});

  @override
  State<InOutInputPage> createState() => _InOutInputState();
}

class _InOutInputState extends State<InOutInputPage> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final InOutController _inOutController = InOutController();
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    var today = DateTime.now();
    _inOutController.update(true, inOutList: null, error: null);
    globalDatabase
        .listInOutByCreation(today.year,
            month: today.month, day: today.day, reversed: true)
        .then((value) {
      _inOutController.update(false, inOutList: value);
    }, onError: (error) {
      _inOutController.update(false, error: error.toString(), inOutList: null);
    });

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
                      maxLength: 30,
                      maxLines: 1,
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
                ],
              ),
              const SizedBox(height: 10),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                        minimumSize:
                            MaterialStateProperty.all(const Size(0, 60)),
                      ),
                      onPressed: () => _save(invert: false),
                      child: const Text("Entrada",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        minimumSize:
                            MaterialStateProperty.all(const Size(0, 60)),
                      ),
                      onPressed: () => _save(invert: true),
                      child: const Text("Saída",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Today list
              InOutList(
                _inOutController,
                deleteButton: true,
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

    final String description = _descriptionController.text;

    globalDatabase.insertInOut(value, description: description);

    _valueController.clear();
    _descriptionController.clear();

    setState(() {
      _error = false;
    });
  }
}
