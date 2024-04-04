import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mexanyd_desktop/database/interface.dart';

class InOutInput extends StatefulWidget {
  const InOutInput({super.key});

  @override
  State<InOutInput> createState() => _InOutInputState();
}

class _InOutInputState extends State<InOutInput> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    var today = DateTime.timestamp();

    return Material(
      child: Container(
        margin: const EdgeInsets.only(top: 30, left: 15, right: 15),
        child: Column(
          children: [
            // Title
            const Text("Entrada/Saída",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
            // TextFields
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _valueController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                        FilteringTextInputFormatter.deny(RegExp(r','),
                            replacementString: '.'),
                      ],
                      maxLength: 7,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "Valor",
                        counterText: "",
                        errorText: _error ? "Valor inválido" : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      margin: const EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: "Descrição",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Buttons
            Container(
              margin: const EdgeInsets.only(top: 20),
              constraints: const BoxConstraints(maxWidth: 715),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                        minimumSize:
                            MaterialStateProperty.all(const Size(0, 60)),
                      ),
                      onPressed: () {
                        try {
                          final double value =
                              double.parse(_valueController.text);
                          final String description =
                              _descriptionController.text;
                          globalDatabase.insertInOut(value,
                              description: description);
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
                      },
                      child: const Text("Entrada",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                          minimumSize:
                              MaterialStateProperty.all(const Size(0, 60)),
                        ),
                        onPressed: () {
                          try {
                            final double value =
                                double.parse(_valueController.text);
                            final String description =
                                _descriptionController.text;
                            globalDatabase.insertInOut(-value,
                                description: description);
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
                        },
                        child: const Text("Saída",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Today list
            FutureBuilder(
                future: globalDatabase.listInOutByCreation(today.year,
                    month: today.month, day: today.day, limit: 100000),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 50),
                        constraints: const BoxConstraints(maxWidth: 715),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[300],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: CustomScrollView(
                          shrinkWrap: true,
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = snapshot.data?[index];
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, left: 20, right: 20),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background),
                                    child: ListTile(
                                      title: item!.description.isEmpty
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    item.value
                                                        .toStringAsFixed(2),
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: item.value > 0
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    item.value
                                                        .toStringAsFixed(2),
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: item.value > 0
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Text(
                                                  item.description,
                                                ),
                                              ],
                                            ),
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
                }),
          ],
        ),
      ),
    );
  }
}
