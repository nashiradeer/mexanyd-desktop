import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/inout/base.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class InOutListPage extends StatefulWidget {
  const InOutListPage({super.key});

  @override
  State<InOutListPage> createState() => _InOutListState();
}

class _InOutListState extends State<InOutListPage> {
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final InOutController _inOutController = InOutController();

  bool _yearError = false;
  bool _monthError = false;
  bool _dayError = false;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    _yearController.text = today.year.toString().padLeft(4, "0");
    _monthController.text = today.month.toString().padLeft(2, "0");
    _dayController.text = today.day.toString().padLeft(2, "0");

    _fetch();

    return MexanydPage(
      title: "Listar",
      icon: Icons.list_alt_rounded,
      actions: [
        MexanydPageButton(
          text1: "Entrada",
          text2: "Saída",
          icon: Icons.swap_vert_rounded,
          onPressed: () => Navigator.popAndPushNamed(context, "/inout"),
        ),
        const SizedBox(height: 5),
        const MexanydPageButton(
          text1: "Listar",
          icon: Icons.list_alt_rounded,
          onPressed: null,
        ),
      ],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: TextField(
                      maxLength: 4,
                      maxLines: 1,
                      controller: _yearController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Ano",
                        counterText: "",
                        errorText: _yearError ? "Inválido" : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      maxLength: 2,
                      maxLines: 1,
                      controller: _monthController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Mês",
                        counterText: "",
                        errorText: _monthError ? "Inválido" : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      maxLength: 2,
                      maxLines: 1,
                      controller: _dayController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Dia",
                        counterText: "",
                        errorText: _dayError ? "Inválido" : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  onPressed: _fetch,
                  child: const Text("Buscar",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        minimumSize:
                            MaterialStateProperty.all(const Size(0, 60)),
                      ),
                      onPressed: () {},
                      child: const Text("Imprimir",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        minimumSize:
                            MaterialStateProperty.all(const Size(0, 60)),
                      ),
                      onPressed: () {},
                      child: const Text("Exportar",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InOutList(_inOutController),
            ],
          ),
        ),
      ),
    );
  }

  String _stringOrDefault(String value, String defaultValue) {
    return value.isEmpty ? defaultValue : value;
  }

  void _fetch() {
    final today = DateTime.now();

    final year = int.tryParse(
        _stringOrDefault(_yearController.text, today.year.toString()));
    final month = int.tryParse(
        _stringOrDefault(_monthController.text, today.month.toString()));
    final day = int.tryParse(
        _stringOrDefault(_dayController.text, today.day.toString()));

    if (year == null) {
      setState(() {
        _yearError = true;
      });

      return;
    } else {
      setState(() {
        _yearError = false;
      });
    }

    if (month == null || month < 1 || month > 12) {
      setState(() {
        _monthError = true;
      });

      return;
    } else {
      setState(() {
        _monthError = false;
      });
    }

    if (day == null || day < 1 || day > 31) {
      setState(() {
        _dayError = true;
      });

      return;
    } else {
      setState(() {
        _dayError = false;
      });
    }

    _inOutController.update(true, inOutList: null, error: null);
    globalDatabase.listInOut(year, month, day: day).then((value) {
      _inOutController.update(false, inOutList: value);
    }, onError: (error) {
      _inOutController.update(false, error: error.toString(), inOutList: null);
    });
  }
}
