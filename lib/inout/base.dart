import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/main.dart';
import 'package:mexanyd_desktop/widgets/list_item.dart';
import 'package:mexanyd_desktop/widgets/paginator.dart';

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

  @override
  Widget build(BuildContext context) {
    final year = widget.controller.year;
    final month = widget.controller.month;
    final day = widget.controller.day;

    return Paginator<InOut, double>(
      itemBuilder: (context, item) => MexanydListItem(
        icon: _typeToIcon(item.type),
        top: DateFormat.yMd(appController.locale?.toLanguageTag())
            .add_Hms()
            .format(item.creation),
        highlight: "R\$ ${item.value.toStringAsFixed(2)}",
        highlightColor: (item.value < 0) ? Colors.red : Colors.green,
        description: item.description,
        boldDescription: true,
        buttonIcon: widget.deleteButton ? const Icon(Icons.delete) : null,
        buttonColor: Colors.red,
        onClick: widget.deleteButton
            ? () {
                globalDatabase.deleteInOut(item.id).then((value) {
                  _updateWidget();
                });
              }
            : null,
      ),
      headerBuilder: (context, header) => Text(
        AppLocalizations.of(context)!
            .totalMoney((header ?? 0).toStringAsFixed(2)),
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      fetcher: (params) => globalDatabase.listInOut(year, month,
          day: day,
          limit: params.pageSize,
          offset: params.offset,
          reversed: widget.reversed),
      prefetch: (context) async {
        final stats = await globalDatabase.statsInOut(year, month, day: day);
        return PaginatorPrefetchData(
          stats.count,
          header: stats.total,
        );
      },
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
