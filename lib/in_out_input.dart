import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InOutInput extends StatefulWidget {
  const InOutInput({super.key});

  @override
  State<InOutInput> createState() => _InOutInputState();
}

class _InOutInputState extends State<InOutInput> {
  @override
  Widget build(BuildContext context) {
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
                children: [
                  SizedBox(
                    width: 90,
                    child: TextField(
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
                        throw UnimplementedError();
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
                          throw UnimplementedError();
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
          ],
        ),
      ),
    );
  }
}
