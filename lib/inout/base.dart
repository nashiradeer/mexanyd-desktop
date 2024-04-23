import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/main.dart';

class InOutController extends ChangeNotifier {
  int year;
  int month;
  int? day;

  InOutController(this.year, this.month, [this.day]);

  static InOutController fromDateTime(DateTime dateTime) {
    return InOutController(dateTime.year, dateTime.month, dateTime.day);
  }

  static InOutController fromDateTimeNow() {
    final now = DateTime.now();
    return InOutController.fromDateTime(now);
  }

  static InOutController fromDateTimeMonth(DateTime dateTime) {
    return InOutController(dateTime.year, dateTime.month);
  }

  static InOutController fromDateTimeMonthNow() {
    final now = DateTime.now();
    return InOutController.fromDateTimeMonth(now);
  }

  void fetch(int year, int month, [int? day]) {
    this.year = year;
    this.month = month;
    this.day = day;
    notifyListeners();
  }

  void reload() {
    notifyListeners();
  }
}

class _InOutData {
  final List<InOut> data;
  final int pageCount;
  final double totalValue;

  const _InOutData(this.data, this.pageCount, this.totalValue);
}

class InOutList extends StatefulWidget {
  final InOutController controller;
  final bool deleteButton;
  final int itemPerPage;
  final bool reversed;

  const InOutList(this.controller,
      {super.key,
      this.deleteButton = false,
      this.itemPerPage = 30,
      this.reversed = false});

  @override
  State<InOutList> createState() => _InOutListState();
}

class _InOutListState extends State<InOutList> {
  int page = 0;
  int pageCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateWidget);
    super.dispose();
  }

  void _updateWidget() {
    setState(() {});
  }

  void _nextPage() {
    if (page < pageCount - 1) {
      setState(() {
        page++;
      });
    }
  }

  void _prevPage() {
    if (page > 0) {
      setState(() {
        page--;
      });
    }
  }

  Future<_InOutData> _fetchData() async {
    final year = widget.controller.year;
    final month = widget.controller.month;
    final day = widget.controller.day;

    final stats = await globalDatabase.statsInOut(year, month, day: day);
    final pageCount = (stats.count / widget.itemPerPage).ceil();
    final data = await globalDatabase.listInOut(year, month,
        day: day,
        limit: widget.itemPerPage,
        offset: page * widget.itemPerPage,
        reversed: widget.reversed);

    return _InOutData(data, pageCount, stats.total);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data as _InOutData;

            if (data.data.isEmpty) {
              return _buildEmpty();
            }

            if (data.pageCount != pageCount) {
              page = 0;
              pageCount = data.pageCount;
            }

            return _buildList(data);
          } else if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          return _buildLoading();
        });
  }

  Widget _buildLoading() {
    return const Expanded(
      child: Center(
        child: SizedBox.square(
          dimension: 80,
          child: CircularProgressIndicator(
            strokeWidth: 15,
            strokeCap: StrokeCap.round,
            strokeAlign: -1,
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 100, color: Colors.red),
          Text(
            AppLocalizations.of(context)!.error,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(message),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Expanded(
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.noDataFound,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildList(_InOutData data) {
    return Expanded(
      child: Column(
        children: [
          _buildPaginator(data.totalValue),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.data.length,
              itemBuilder: (context, index) {
                final inOut = data.data[index];
                return _InOutItem(
                    inOut, widget.controller, widget.deleteButton);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginator(double totalValue) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!
              .totalMoney(totalValue.toStringAsFixed(2)),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          onPressed: (page > 0) ? _prevPage : null,
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
        Text("${page + 1}/$pageCount"),
        IconButton(
          onPressed: (page < pageCount - 1) ? _nextPage : null,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
      ],
    );
  }
}

class _InOutItem extends StatelessWidget {
  final InOut inOut;
  final bool deleteButton;
  final InOutController controller;

  const _InOutItem(this.inOut, this.controller, [this.deleteButton = false]);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20, bottom: 5, top: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMd(appController.locale?.toLanguageTag())
                  .add_Hms()
                  .format(inOut.creation),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .totalMoney(inOut.value.toStringAsFixed(2)),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: (inOut.value < 0) ? Colors.red : Colors.green),
                ),
                if (inOut.description.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      inOut.description,
                      style: const TextStyle(fontSize: 20),
                      softWrap: true,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        leading: Icon(
          _typeToIcon(inOut.type),
          color: Theme.of(context).colorScheme.primary,
        ),
        trailing: deleteButton
            ? IconButton(
                onPressed: () {
                  globalDatabase.deleteInOut(inOut.id).then((value) {
                    controller.reload();
                  });
                },
                icon: const Icon(Icons.delete),
              )
            : null,
      ),
    );
  }

  IconData _typeToIcon(InOutType type) {
    switch (type) {
      case InOutType.money:
        return Icons.money_rounded;
      case InOutType.credit:
        return Icons.credit_card_rounded;
      case InOutType.future:
        return Icons.alarm_rounded;
    }
  }
}
