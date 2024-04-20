import 'package:intl/intl.dart';
import 'package:mexanyd_desktop/database/interface.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void printDayInOut(int year, int month, int day) async {
  const itemsPerPage = 40;
  final pageCount =
      await globalDatabase.countInOut(year, month, day) ~/ itemsPerPage + 1;
  final total = await globalDatabase.totalInOut(year, month, day);

  final pdf = pw.Document();

  for (var i = 0; i < pageCount; i++) {
    final items = await globalDatabase.listInOut(year, month,
        day: day, limit: itemsPerPage, offset: i * itemsPerPage);

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
                  DateFormat.yMd().format(DateTime(year, month, day)),
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
                          'Hora',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          'Tipo',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          'Descrição',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1),
                        child: pw.Text(
                          'Valor',
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
                            DateFormat.Hm().format(item.creation),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Text(
                            _typeToString(item.type),
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
                  'R\$ ${total.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.center,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1.0),
                  color: PdfColors.grey400,
                ),
              ),
              pw.SizedBox(
                width: double.infinity,
                child: pw.Text('Página ${i + 1} de $pageCount',
                    textAlign: pw.TextAlign.right),
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

String _typeToString(InOutType type) {
  switch (type) {
    case InOutType.money:
      return 'Dinheiro';
    case InOutType.credit:
      return 'Cartão';
    case InOutType.future:
      return 'Prazo';
  }
}
