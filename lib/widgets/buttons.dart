import 'package:flutter/material.dart';

/// Controller for Radio Buttons from Mexanyd.
class MexanydRadioController extends ChangeNotifier {
  /// The index of the selected radio button.
  int _selectedIndex = 0;

  /// Constructor for [MexanydRadioController].
  MexanydRadioController([selectedIndex = 0]) : _selectedIndex = selectedIndex;

  /// Get the selected index.
  int get selectedIndex => _selectedIndex;

  /// Set the selected index.
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

/// Group of radio buttons with icons.
class MexanydIconRadio extends StatefulWidget {
  /// List of icons for the radio buttons.
  final List<IconData> icons;

  /// Size of the icons.
  final double size;

  /// Border radius of the radio buttons.
  final double borderRadius;

  /// Color of the selected radio button.
  final Color? selectedColor;

  /// Color of the unselected radio buttons.
  final Color? unselectedColor;

  /// Function to call when the selected index changes.
  final Function(int)? onChanged;

  /// Controller for the radio buttons.
  final MexanydRadioController? controller;

  /// Index of the selected radio button.
  final int selectedIndex;

  /// Constructor for [MexanydIconRadio].
  const MexanydIconRadio({
    super.key,
    required this.icons,
    this.controller,
    this.size = 30,
    this.borderRadius = 10,
    this.selectedIndex = 0,
    this.selectedColor,
    this.unselectedColor,
    this.onChanged,
  });

  @override
  State<MexanydIconRadio> createState() => _MexanydIconRadioState();
}

/// State for [MexanydIconRadio].
class _MexanydIconRadioState extends State<MexanydIconRadio> {
  /// Index of the selected radio button.
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      widget.controller!.addListener(_updateState);
      selectedIndex = widget.controller!.selectedIndex;
    } else {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.removeListener(_updateState);
    }

    super.dispose();
  }

  /// Update the index using the controller.
  void _updateState() {
    setState(() {
      selectedIndex = widget.controller!.selectedIndex;
    });
  }

  /// Get the foreground color of the radio button.
  Color _foregroundColor(int index, BuildContext context) {
    return selectedIndex == index
        ? widget.selectedColor ?? Theme.of(context).colorScheme.background
        : widget.unselectedColor ?? Theme.of(context).colorScheme.primary;
  }

  /// Get the background color of the radio button.
  Color _backgroundColor(int index, BuildContext context) {
    return selectedIndex == index
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
              if (widget.controller != null) {
                widget.controller!.setSelectedIndex(0);
              } else {
                setState(() {
                  selectedIndex = 0;
                });
              }

              if (widget.onChanged != null) {
                widget.onChanged!(0);
              }
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
                if (widget.controller != null) {
                  widget.controller!.setSelectedIndex(index);
                } else {
                  setState(() {
                    selectedIndex = index;
                  });
                }

                if (widget.onChanged != null) {
                  widget.onChanged!(index);
                }
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
              if (widget.controller != null) {
                widget.controller!.setSelectedIndex(widget.icons.length - 1);
              } else {
                setState(() {
                  selectedIndex = widget.icons.length - 1;
                });
              }

              if (widget.onChanged != null) {
                widget.onChanged!(widget.icons.length - 1);
              }
            },
          ),
        ),
      ],
    );
  }
}

/// Data for the [MexanydIconButton].
class MexanydIconButtonData {
  /// Icon for the button.
  final IconData icon;

  /// Function to call when the button is pressed.
  final void Function()? onPressed;

  /// Background color of the button.
  final Color? backgroundColor;

  /// Foreground color of the button.
  final Color? foregroundColor;

  /// Constructor for [MexanydIconButtonData].
  const MexanydIconButtonData({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}

/// Group of icon buttons.
class MexanydIconButton extends StatelessWidget {
  /// List of data for the icon buttons.
  final List<MexanydIconButtonData> data;

  /// Size of the icons.
  final double size;

  /// Border radius of the icon buttons.
  final double borderRadius;

  /// Constructor for [MexanydIconButton].
  const MexanydIconButton({
    super.key,
    required this.data,
    this.size = 30,
    this.borderRadius = 10,
  });

  /// Get the background color of the icon button, default to primary color.
  Color _backgroundColor(Color? color, BuildContext context) {
    return color ?? Theme.of(context).colorScheme.primary;
  }

  /// Get the foreground color of the icon button, default to background color.
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
