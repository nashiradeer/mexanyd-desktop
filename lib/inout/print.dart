import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:mexanyd_desktop/main.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void printMonthInOut(int year, int month, BuildContext buildContext) async {
  final days =
      SplayTreeMap.from(await globalDatabase.totalInOutByDay(year, month));
  final daysCount = DateTime(year, month + 1, 0).day;

  for (var i = 1; i <= daysCount; i++) {
    days.putIfAbsent(i, () => const InOutDayTotal(0, 0, 0, 0));
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.only(top: 1, bottom: 1),
              child: pw.Text(
                DateFormat.yMMMM(appController.locale?.toLanguageTag())
                    .format(DateTime(year, month)),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1.0),
                color: PdfColors.grey400,
              ),
            ),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
              columnWidths: {
                0: const pw.FixedColumnWidth(20),
                1: const pw.FixedColumnWidth(40),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey400,
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        AppLocalizations.of(buildContext)!.compactNumber,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        AppLocalizations.of(buildContext)!.day,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        AppLocalizations.of(buildContext)!.money,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        AppLocalizations.of(buildContext)!.card,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        AppLocalizations.of(buildContext)!.future,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        AppLocalizations.of(buildContext)!.total,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                for (var item in days.entries)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          item.key.toString(),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          DateFormat.E(appController.locale?.toLanguageTag())
                              .format(DateTime(year, month, item.key)),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          item.value.money != 0
                              ? item.value.money.toStringAsFixed(2)
                              : '',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          item.value.credit != 0
                              ? item.value.credit.toStringAsFixed(2)
                              : '',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          item.value.future != 0
                              ? item.value.future.toStringAsFixed(2)
                              : '',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          item.value.total != 0
                              ? item.value.total.toStringAsFixed(2)
                              : '',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey400,
                  ),
                  children: [
                    pw.Text(''),
                    pw.Text(''),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        days.values
                            .fold(0.0, (prev, element) => prev + element.money)
                            .toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        days.values
                            .fold(0.0, (prev, element) => prev + element.credit)
                            .toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        days.values
                            .fold(0.0, (prev, element) => prev + element.future)
                            .toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(1),
                      child: pw.Text(
                        days.values
                            .fold(0.0, (prev, element) => prev + element.total)
                            .toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  Printing.layoutPdf(
    onLayout: (format) => pdf.save(),
    usePrinterSettings: true,
    format: PdfPageFormat.a4,
  );
}

void printDayInOut(
    int year, int month, int day, BuildContext buildContext) async {
  const itemsPerPage = 40;
  final stats = await globalDatabase.statsInOut(year, month, day: day);
  final pageCount = stats.count ~/ itemsPerPage + 1;

  final pdf = pw.Document();

  for (var i = 0; i < pageCount; i++) {
    final items = await globalDatabase.listInOut(
      year,
      month,
      day: day,
      limit: itemsPerPage,
      offset: i * itemsPerPage,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(top: 1, bottom: 1),
                child: pw.Text(
                  DateFormat.yMd(appController.locale?.toLanguageTag())
                      .format(DateTime(year, month, day)),
                  textAlign: pw.TextAlign.center,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1.0),
                  color: PdfColors.grey400,
                ),
              ),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FixedColumnWidth(60),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FixedColumnWidth(65),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey400,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          AppLocalizations.of(buildContext)!.time,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          AppLocalizations.of(buildContext)!.type,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          AppLocalizations.of(buildContext)!.description,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          AppLocalizations.of(buildContext)!.value,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  for (final item in items)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Text(
                            DateFormat.Hm(appController.locale?.toLanguageTag())
                                .format(item.creation),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Text(
                            _typeToString(item.type, buildContext),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(5, 1, 5, 1),
                          child: pw.Text(
                            item.description,
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(5, 1, 5, 1),
                          child: pw.Text(
                            item.value.toStringAsFixed(2),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(top: 1, bottom: 1),
                child: pw.Text(
                  AppLocalizations.of(buildContext)!
                      .totalMoney(stats.total.toStringAsFixed(2)),
                  textAlign: pw.TextAlign.center,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1.0),
                  color: PdfColors.grey400,
                ),
              ),
              pw.SizedBox(
                width: double.infinity,
                child: pw.Text(
                  AppLocalizations.of(buildContext)!.page(i + 1, pageCount),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Printing.layoutPdf(
    onLayout: (format) => pdf.save(),
    usePrinterSettings: true,
    format: PdfPageFormat.a4,
  );
}

String _typeToString(InOutType type, BuildContext context) {
  switch (type) {
    case InOutType.money:
      return AppLocalizations.of(context)!.money;
    case InOutType.credit:
      return AppLocalizations.of(context)!.card;
    case InOutType.future:
      return AppLocalizations.of(context)!.future;
  }
}
