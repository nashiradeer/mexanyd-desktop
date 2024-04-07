import 'package:flutter/material.dart';

class InOutListPage extends StatefulWidget {
  const InOutListPage({super.key});

  @override
  State<InOutListPage> createState() => _InOutListState();
}

class _InOutListState extends State<InOutListPage> {
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
      body: const Material(),
    );
  }
}
