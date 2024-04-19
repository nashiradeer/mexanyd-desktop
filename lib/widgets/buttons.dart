import 'package:flutter/material.dart';

class MexanydRadioController extends ChangeNotifier {
  int _selectedIndex;

  MexanydRadioController([selectedIndex = 0]) : _selectedIndex = selectedIndex;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

class MexanydIconRadio extends StatefulWidget {
  final List<IconData> icons;
  final MexanydRadioController controller;
  final double size;
  final double borderRadius;
  final Color? selectedColor;
  final Color? unselectedColor;

  const MexanydIconRadio({
    super.key,
    required this.icons,
    required this.controller,
    this.size = 30,
    this.borderRadius = 10,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  State<MexanydIconRadio> createState() => _MexanydIconRadioState();
}

class _MexanydIconRadioState extends State<MexanydIconRadio> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(updateState);
    super.dispose();
  }

  void updateState() {
    setState(() {});
  }

  Color foregroundColor(int index, BuildContext context) {
    return widget.controller.selectedIndex == index
        ? widget.selectedColor ?? Theme.of(context).colorScheme.background
        : widget.unselectedColor ?? Theme.of(context).colorScheme.primary;
  }

  Color backgroundColor(int index, BuildContext context) {
    return widget.controller.selectedIndex == index
        ? widget.selectedColor ?? Theme.of(context).colorScheme.primary
        : widget.unselectedColor ??
            Theme.of(context).colorScheme.surfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.icons.length < 2) {
      throw Exception('icons length must be greater than 1');
    }

    final icons = List.from(widget.icons);
    final first = icons.removeAt(0);
    final last = icons.removeLast();

    return Row(
      children: [
        Expanded(
          child: IconButton(
            icon: Icon(first),
            iconSize: widget.size,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.borderRadius),
                    bottomLeft: Radius.circular(widget.borderRadius),
                  ),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all(backgroundColor(0, context)),
            ),
            color: foregroundColor(0, context),
            onPressed: () {
              widget.controller.setSelectedIndex(0);
            },
          ),
        ),
        ...icons.map((icon) {
          final index = icons.indexOf(icon) + 1;
          return Expanded(
            child: IconButton(
              icon: Icon(icon),
              iconSize: widget.size,
              style: ButtonStyle(
                shape:
                    MaterialStateProperty.all(const RoundedRectangleBorder()),
                backgroundColor:
                    MaterialStateProperty.all(backgroundColor(index, context)),
              ),
              color: foregroundColor(index, context),
              onPressed: () {
                widget.controller.setSelectedIndex(index);
              },
            ),
          );
        }),
        Expanded(
          child: IconButton(
            icon: Icon(last),
            iconSize: widget.size,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(widget.borderRadius),
                    bottomRight: Radius.circular(widget.borderRadius),
                  ),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(
                  backgroundColor(icons.length + 1, context)),
            ),
            color: foregroundColor(icons.length + 1, context),
            onPressed: () {
              widget.controller.setSelectedIndex(icons.length + 1);
            },
          ),
        ),
      ],
    );
  }
}
