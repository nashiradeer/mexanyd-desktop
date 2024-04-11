import 'package:flutter/material.dart';
import 'package:mexanyd_desktop/database/interface.dart';

class InOutController extends ChangeNotifier {
  List<InOut>? _inOutList;
  String? _error;
  bool _loading = false;

  void update(bool loading, {List<InOut>? inOutList, String? error}) {
    _inOutList = inOutList;
    _error = error;
    _loading = loading;
    notifyListeners();
  }
}

class InOutList extends StatefulWidget {
  final InOutController controller;
  final bool deleteButton;

  const InOutList(this.controller, {super.key, this.deleteButton = false});

  @override
  State<InOutList> createState() => _InOutListState();
}

class _InOutListState extends State<InOutList> {
  @override
  Widget build(BuildContext context) {
    final loading = widget.controller._loading;
    final error = widget.controller._error;
    final inOutList = widget.controller._inOutList;

    if (inOutList != null && inOutList.isNotEmpty) {
      return _buildList(widget.controller._inOutList!);
    } else if (error != null) {
      return _buildError(error);
    } else if (loading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 10,
              strokeAlign: 1,
              strokeCap: StrokeCap.round,
              color: Colors.blue),
        ),
      );
    } else {
      return const Expanded(
        child: Center(
          child: Text(
            "Nenhum item encontrado.",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  Widget _buildError(String error) {
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
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(error),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<InOut> items) {
    return Expanded(
      child: Column(
        children: [
          Text(
            "Total: ${items.fold(0.0, (previousValue, element) => previousValue + element.value).toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        return InOutListItem(
                          item,
                          trailing: (widget.deleteButton)
                              ? IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    globalDatabase.deleteInOut(item.id).then(
                                      (value) {
                                        items.remove(item);
                                        setState(() {});
                                      },
                                    );
                                  },
                                )
                              : null,
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InOutListItem extends StatelessWidget {
  final InOut inOut;
  final Widget? trailing;

  const InOutListItem(this.inOut, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5, left: 5, right: 15),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).colorScheme.surfaceVariant),
      child: ListTile(
        title: _generate(),
        trailing: trailing,
      ),
    );
  }

  Widget _generate() {
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            inOut.value.toStringAsFixed(2),
            textAlign: TextAlign.end,
            style: TextStyle(
              color: inOut.value > 0 ? Colors.green : Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    if (inOut.description.isNotEmpty) {
      row.children.add(const SizedBox(width: 20));
      row.children.add(Text(inOut.description));
    }

    return row;
  }
}
