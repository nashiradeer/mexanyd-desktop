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
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  Color _foregroundColor(int index, BuildContext context) {
    return widget.controller.selectedIndex == index
        ? widget.selectedColor ?? Theme.of(context).colorScheme.background
        : widget.unselectedColor ?? Theme.of(context).colorScheme.primary;
  }

  Color _backgroundColor(int index, BuildContext context) {
    return widget.controller.selectedIndex == index
        ? widget.selectedColor ?? Theme.of(context).colorScheme.primary
        : widget.unselectedColor ??
            Theme.of(context).colorScheme.surfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.icons.length < 2) {
      throw Exception('Needs at least 2 icons to work properly');
    }

    return Row(
      children: [
        Expanded(
          child: IconButton(
            icon: Icon(widget.icons.first),
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
                  MaterialStateProperty.all(_backgroundColor(0, context)),
            ),
            color: _foregroundColor(0, context),
            onPressed: () {
              widget.controller.setSelectedIndex(0);
            },
          ),
        ),
        ...widget.icons.sublist(1, widget.icons.length - 1).map((icon) {
          final index = widget.icons.indexOf(icon);
          return Expanded(
            child: IconButton(
              icon: Icon(icon),
              iconSize: widget.size,
              style: ButtonStyle(
                shape:
                    MaterialStateProperty.all(const RoundedRectangleBorder()),
                backgroundColor:
                    MaterialStateProperty.all(_backgroundColor(index, context)),
              ),
              color: _foregroundColor(index, context),
              onPressed: () {
                widget.controller.setSelectedIndex(index);
              },
            ),
          );
        }),
        Expanded(
          child: IconButton(
            icon: Icon(widget.icons.last),
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
                  _backgroundColor(widget.icons.length - 1, context)),
            ),
            color: _foregroundColor(widget.icons.length - 1, context),
            onPressed: () {
              widget.controller.setSelectedIndex(widget.icons.length - 1);
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
      throw Exception('Needs at least 2 icons to work properly');
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: IconButton(
            icon: Icon(data.first.icon),
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
                  _backgroundColor(data.first.backgroundColor, context)),
            ),
            color: _foregroundColor(data.first.foregroundColor, context),
            onPressed: data.first.onPressed,
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
            icon: Icon(data.last.icon),
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
                  _backgroundColor(data.last.backgroundColor, context)),
            ),
            color: _foregroundColor(data.last.foregroundColor, context),
            onPressed: data.last.onPressed,
          ),
        ),
      ],
    );
  }
}
