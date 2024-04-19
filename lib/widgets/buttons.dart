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

class MexanydIconButtonData {
  final IconData icon;
  final void Function()? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const MexanydIconButtonData({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}

class MexanydIconButton extends StatelessWidget {
  final List<MexanydIconButtonData> data;
  final double size;
  final double borderRadius;

  const MexanydIconButton({
    super.key,
    required this.data,
    this.size = 30,
    this.borderRadius = 10,
  });

  Color _backgroundColor(Color? color, BuildContext context) {
    return color ?? Theme.of(context).colorScheme.primary;
  }

  Color _foregroundColor(Color? color, BuildContext context) {
    return color ?? Theme.of(context).colorScheme.background;
  }

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      throw Exception('Buttons length must be greater than 1');
    }

    final first = data.first;
    final last = data.last;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: IconButton(
            icon: Icon(first.icon),
            iconSize: size,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    bottomLeft: Radius.circular(borderRadius),
                  ),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(
                  _backgroundColor(first.backgroundColor, context)),
            ),
            color: _foregroundColor(first.foregroundColor, context),
            onPressed: first.onPressed,
          ),
        ),
        ...data.sublist(1, data.length - 1).map((d) {
          return Expanded(
            child: IconButton(
              icon: Icon(d.icon),
              iconSize: size,
              style: ButtonStyle(
                shape:
                    MaterialStateProperty.all(const RoundedRectangleBorder()),
                backgroundColor: MaterialStateProperty.all(
                    _backgroundColor(d.backgroundColor, context)),
              ),
              color: _foregroundColor(d.foregroundColor, context),
              onPressed: d.onPressed,
            ),
          );
        }),
        Expanded(
          child: IconButton(
            icon: Icon(last.icon),
            iconSize: size,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(borderRadius),
                    bottomRight: Radius.circular(borderRadius),
                  ),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(
                  _backgroundColor(last.backgroundColor, context)),
            ),
            color: _foregroundColor(last.foregroundColor, context),
            onPressed: last.onPressed,
          ),
        ),
      ],
    );
  }
}
