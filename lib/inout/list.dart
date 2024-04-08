import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/theme.dart';

class InOutListPage extends StatefulWidget {
  const InOutListPage({super.key});

  @override
  State<InOutListPage> createState() => _InOutListState();
}

class _InOutListState extends State<InOutListPage> {
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();

  bool _yearError = false;
  bool _monthError = false;
  bool _dayError = false;

  Future<List<InOut>?>? _operation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Entrada/Saída",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
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
              _process(),
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

    setState(() {
      _operation = globalDatabase.listInOutByCreation(year,
          month: month, day: day, limit: 100000);
    });
  }

  Widget _process() {
    if (_operation == null) {
      return const Expanded(
        child: Center(
          child: Text("Nenhum dado a ser exibido",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      return FutureBuilder(
        future: _operation,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _parse(snapshot);
          } else if (snapshot.hasError) {
            return Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 150,
                    ),
                    const SizedBox(height: 10),
                    const Text("Erro ao carregar dados",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(snapshot.error.toString()),
                  ],
                ),
              ),
            );
          } else {
            return const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 10,
                    strokeAlign: 1,
                    strokeCap: StrokeCap.round,
                    color: Colors.deepPurpleAccent),
              ),
            );
          }
        },
      );
    }
  }

  Widget _parse(AsyncSnapshot snapshot) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: listBackground(context),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = snapshot.data?[index];
                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: 5, left: 5, right: 15),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Theme.of(context).colorScheme.background),
                    child: ListTile(
                      title: _generate(item),
                    ),
                  );
                },
                childCount: snapshot.data?.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _generate(InOut? item) {
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            item!.value.toStringAsFixed(2),
            textAlign: TextAlign.end,
            style: TextStyle(
              color: item.value > 0 ? Colors.green : Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    if (item.description.isNotEmpty) {
      row.children.add(const SizedBox(width: 20));
      row.children.add(Text(item.description));
    }

    return row;
  }
}
