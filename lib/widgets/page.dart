import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// A page widget that can be used to create a page with a header, window buttons and side menu.
class MexanydPage extends StatelessWidget {
  /// The title of the page.
  final String? title;

  /// The icon of the page.
  final IconData? icon;

  /// The child widget of the page.
  final Widget child;

  /// The actions for the side menu.
  final List<Widget>? actions;

  /// Creates a new MexanydPage.
  const MexanydPage(
      {super.key, required this.child, this.title, this.icon, this.actions});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Row(
              children: [
                if (actions != null) _buildActions(context),
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the header of the page.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (event) {
              windowManager.startDragging();
            },
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: Row(
                children: [
                  if (icon != null) _buildIcon(context),
                  if (title != null) const Spacer(),
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 150),
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        _buildWindowButtons(context),
      ],
    );
  }

  /// Builds the icon of the page.
  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Icon(icon, size: 25, color: Theme.of(context).colorScheme.primary),
    );
  }

  /// Builds the window buttons of the page.
  Widget _buildWindowButtons(BuildContext context) {
    return Row(
      children: [
        WindowButton(
          onPressed: () => WindowManager.instance.minimize(),
          icon: const Icon(Icons.minimize),
        ),
        const MaximizeButton(),
        WindowButton(
          onPressed: () => WindowManager.instance.close(),
          icon: const Icon(Icons.close),
          danger: true,
        ),
      ],
    );
  }

  /// Builds the actions for the side menu.
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: actions!,
      ),
    );
  }
}

/// A button that can be used in the side menu of a [MexanydPage].
class MexanydPageButton extends StatelessWidget {
  /// The first text of the button.
  final String text1;

  /// The second text of the button.
  final String? text2;

  /// The icon of the button.
  final IconData icon;

  /// The function that is called when the button is pressed.
  final void Function()? onPressed;

  /// Creates a new [MexanydPageButton].
  const MexanydPageButton({
    super.key,
    required this.text1,
    required this.onPressed,
    required this.icon,
    this.text2,
  });

  /// Creates a copy of the button that is disabled.
  static MexanydPageButton copyDisabled(MexanydPageButton button) {
    return MexanydPageButton(
      text1: button.text1,
      text2: button.text2,
      icon: button.icon,
      onPressed: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 65,
      child: TextButton(
        onPressed: onPressed,
        style: _generateStyle(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(context),
            _buildText(context),
          ],
        ),
      ),
    );
  }

  /// Builds the text of the button.
  Widget _buildText(BuildContext context) {
    if (text2 == null) {
      return Text(text1, style: const TextStyle(fontSize: 12));
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text1, style: const TextStyle(fontSize: 10)),
          Text(text2!, style: const TextStyle(fontSize: 10)),
        ],
      );
    }
  }

  /// Builds the icon of the button.
  Widget _buildIcon(BuildContext context) {
    if (text2 == null) {
      return Icon(icon, size: 32);
    } else {
      return Icon(icon, size: 20);
    }
  }

  /// Generates the style of the button.
  ButtonStyle _generateStyle(BuildContext context) {
    return TextButton.styleFrom(
      disabledBackgroundColor: Theme.of(context).colorScheme.primary,
      disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

/// Window button that can be used in the header of a [MexanydPage].
class WindowButton extends StatelessWidget {
  /// The function that is called when the button is pressed.
  final void Function()? onPressed;

  /// The icon of the button.
  final Widget icon;

  /// Whether the button is a danger button.
  final bool danger;

  /// Creates a new [WindowButton].
  const WindowButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: icon,
        iconSize: 20,
        hoverColor: danger ? Colors.red : null,
        style: ButtonStyle(
          iconColor:
              WidgetStatePropertyAll(Theme.of(context).colorScheme.onSurface),
          shape: const WidgetStatePropertyAll(ContinuousRectangleBorder()),
        ));
  }
}

/// Button that can be used to maximize or unmaximize the window.
class MaximizeButton extends StatefulWidget {
  /// The color of the button when hovered.
  final Color? hoverColor;

  /// Creates a new [MaximizeButton].
  const MaximizeButton({super.key, this.hoverColor});

  @override
  State<MaximizeButton> createState() => _MaximizeButtonState();
}

/// State of the [MaximizeButton].
class _MaximizeButtonState extends State<MaximizeButton> with WindowListener {
  @override
  Widget build(BuildContext context) {
    return WindowButton(
      icon: FutureBuilder(
        future: windowManager.isMaximized(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Icon(snapshot.data as bool
                ? Icons.close_fullscreen_rounded
                : Icons.open_in_full_rounded);
          } else {
            return const Icon(Icons.open_in_full_rounded);
          }
        },
      ),
      onPressed: () {
        windowManager.isMaximized().then((value) {
          if (value) {
            windowManager.unmaximize();
          } else {
            windowManager.maximize();
          }
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }
}
