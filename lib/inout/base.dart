import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/main.dart';

/// Controller for the [InOut] list.
class InOutController extends ChangeNotifier {
  /// Year used to filter the list.
  int year;

  /// Month used to filter the list.
  int month;

  /// Day used to filter the list. If null, all days of the month are used.
  int? day;

  /// Creates a new [InOutController].
  InOutController(this.year, this.month, [this.day]);

  /// Creates a new [InOutController] from a [DateTime].
  static InOutController fromDateTime(DateTime dateTime) {
    return InOutController(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Creates a new [InOutController] from the current [DateTime].
  static InOutController fromDateTimeNow() {
    final now = DateTime.now();
    return InOutController.fromDateTime(now);
  }

  /// Creates a new [InOutController] from a [DateTime] with only year and month.
  static InOutController fromDateTimeMonth(DateTime dateTime) {
    return InOutController(dateTime.year, dateTime.month);
  }

  /// Creates a new [InOutController] from the current [DateTime] with only year and month.
  static InOutController fromDateTimeMonthNow() {
    final now = DateTime.now();
    return InOutController.fromDateTimeMonth(now);
  }

  /// Fetches a new list of [InOut]s, changing the year, month and day.
  void fetch(int year, int month, [int? day]) {
    this.year = year;
    this.month = month;
    this.day = day;
    notifyListeners();
  }

  /// Fetches a new list of [InOut]s without changing the year, month and day.
  void reload() {
    notifyListeners();
  }
}

/// Union of [InOut] and [InOutStats].
class _InOutData {
  /// List of [InOut]s.
  final List<InOut> data;

  /// Number of pages.
  final int pageCount;

  /// The sum of all values of the [InOut]s.
  final double totalValue;

  /// Creates a new [_InOutData].
  const _InOutData(this.data, this.pageCount, this.totalValue);
}

/// List of [InOut]s.
class InOutList extends StatefulWidget {
  /// Controller for the list.
  final InOutController controller;

  /// If true, a delete button is shown.
  final bool deleteButton;

  /// Number of items per page.
  final int itemPerPage;

  /// If true, the list is reversed.
  final bool reversed;

  /// Creates a new [InOutList].
  const InOutList(this.controller,
      {super.key,
      this.deleteButton = false,
      this.itemPerPage = 30,
      this.reversed = false});

  @override
  State<InOutList> createState() => _InOutListState();
}

/// State of the [InOutList].
class _InOutListState extends State<InOutList> {
  /// Current page.
  int page = 0;

  /// Number of pages.
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

  /// Updates the widget.
  void _updateWidget() {
    setState(() {});
  }

  /// Goes to the next page.
  void _nextPage() {
    if (page < pageCount - 1) {
      setState(() {
        page++;
      });
    }
  }

  /// Goes to the previous page.
  void _prevPage() {
    if (page > 0) {
      setState(() {
        page--;
      });
    }
  }

  /// Fetches the data.
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

  /// Builds the loading widget.
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

  /// Builds the error widget.
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

  /// Builds the widget when there is no data.
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

  /// Builds the list widget.
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

  /// Builds the paginator widget.
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

/// Item of the [InOutList].
class _InOutItem extends StatelessWidget {
  /// The [InOut] to show.
  final InOut inOut;

  /// If true, a delete button is shown.
  final bool deleteButton;

  /// Controller for the list.
  final InOutController controller;

  /// Creates a new [_InOutItem].
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

  /// Converts an [InOutType] to an [IconData].
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
