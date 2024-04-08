import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/theme.dart';

class InOutInputPage extends StatefulWidget {
  const InOutInputPage({super.key});

  @override
  State<InOutInputPage> createState() => _InOutInputState();
}

class _InOutInputState extends State<InOutInputPage> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    var today = DateTime.now();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          "Entrada/Saída",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/inout/list');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: const Material(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
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
              FutureBuilder(
                future: globalDatabase.listInOutByCreation(today.year,
                    month: today.month, day: today.day, limit: 100000),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save({bool invert = false}) {
    try {
      var value = double.parse(_valueController.text);

      if (invert) {
        value = -value;
      }

      if (value > 99999.99) {
        setState(() {
          _error = true;
        });
        return;
      }

      final String description = _descriptionController.text;

      globalDatabase.insertInOut(value, description: description);

      _valueController.clear();
      _descriptionController.clear();

      setState(() {
        _error = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
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
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          globalDatabase
                              .deleteInOut(item.id)
                              .then((value) => setState(() {}));
                        },
                      ),
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
