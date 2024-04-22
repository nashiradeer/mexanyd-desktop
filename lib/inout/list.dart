import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mexanyd_desktop/inout/base.dart';
import 'package:mexanyd_desktop/inout/print.dart';
import 'package:mexanyd_desktop/widgets/page.dart';

class InOutListPage extends StatefulWidget {
  const InOutListPage({super.key});

  @override
  State<InOutListPage> createState() => _InOutListState();
}

class _InOutListState extends State<InOutListPage> {
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final InOutController _inOutController =
      InOutController.fromDateTimeMonthNow();

  bool _yearError = false;
  bool _monthError = false;
  bool _dayError = false;

  @override
  Widget build(BuildContext context) {
    _yearController.text = _inOutController.year.toString().padLeft(4, "0");
    _monthController.text = _inOutController.month.toString().padLeft(2, "0");
    _dayController.text =
        _inOutController.day?.toString().padLeft(2, "0") ?? "";

    return MexanydPage(
      title: AppLocalizations.of(context)!.list,
      icon: Icons.list_alt_rounded,
      actions: [
        MexanydPageButton(
          text1: AppLocalizations.of(context)!.inNoOut,
          text2: AppLocalizations.of(context)!.out,
          icon: Icons.swap_vert_rounded,
          onPressed: () => Navigator.popAndPushNamed(context, "/inout"),
        ),
        const SizedBox(height: 5),
        MexanydPageButton(
          text1: AppLocalizations.of(context)!.list,
          icon: Icons.list_alt_rounded,
          onPressed: null,
        ),
      ],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 70),
                      SizedBox(
                        width: 110,
                        child: TextField(
                          maxLength: 4,
                          maxLines: 1,
                          controller: _yearController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.year,
                            counterText: "",
                            errorText: _yearError
                                ? AppLocalizations.of(context)!.invalid
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                            _yearController.text =
                                _yearController.text.padLeft(4, "0");
                            _fetch();
                          },
                          onTapOutside: (_) {
                            FocusScope.of(context).unfocus();
                            _yearController.text =
                                _yearController.text.padLeft(4, "0");
                            _fetch();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 110,
                        child: TextField(
                          maxLength: 2,
                          maxLines: 1,
                          controller: _monthController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.month,
                            counterText: "",
                            errorText: _monthError
                                ? AppLocalizations.of(context)!.invalid
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onEditingComplete: () {
                            if (_dayController.text.isEmpty) {
                              FocusScope.of(context).unfocus();
                            } else {
                              FocusScope.of(context).nextFocus();
                            }

                            _monthController.text =
                                _monthController.text.padLeft(2, "0");
                            _fetch();
                          },
                          onTapOutside: (_) {
                            FocusScope.of(context).unfocus();
                            _monthController.text =
                                _monthController.text.padLeft(2, "0");
                            _fetch();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 110,
                        child: TextField(
                          maxLength: 2,
                          maxLines: 1,
                          controller: _dayController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.day,
                            counterText: "",
                            errorText: _dayError
                                ? AppLocalizations.of(context)!.invalid
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();

                            if (_dayController.text.isNotEmpty) {
                              _dayController.text =
                                  _dayController.text.padLeft(2, "0");
                            }

                            _fetch();
                          },
                          onTapOutside: (e) {
                            FocusScope.of(context).unfocus();

                            if (_dayController.text.isNotEmpty) {
                              _dayController.text =
                                  _dayController.text.padLeft(2, "0");
                            }

                            _fetch();
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.print_rounded),
                    iconSize: 40,
                    onPressed: () {
                      if (_yearError || _monthError || _dayError) {
                        return;
                      }

                      final year = _inOutController.year;
                      final month = _inOutController.month;

                      if (_dayController.text.isNotEmpty) {
                        final day = _inOutController.day;
                        printDayInOut(year, month, day!, context);
                      } else {
                        printMonthInOut(year, month, context);
                      }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 10),
              InOutList(_inOutController),
            ],
          ),
        ),
      ),
    );
  }

  void _fetch() {
    final year = int.tryParse(_yearController.text);
    _yearError = year == null || year < 0 || year > 9999;

    final month = int.tryParse(_monthController.text);
    _monthError = month == null || month < 1 || month > 12;

    int? day;
    if (_dayController.text.isNotEmpty) {
      day = int.tryParse(_dayController.text);
      _dayError = day == null || day < 1 || day > 31;
    } else {
      _dayError = false;
    }

    setState(() {});

    if (_yearError || _monthError || _dayError) {
      return;
    }

    _inOutController.fetch(year!, month!, day);
  }
}
