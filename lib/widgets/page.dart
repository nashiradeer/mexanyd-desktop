import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

class MexanydPage extends StatelessWidget {
  final Widget? title;
  final Widget? icon;
  final Widget child;
  final List<Widget>? actions;

  const MexanydPage(
      {super.key, required this.child, this.title, this.icon, this.actions});

  @override
  Widget build(BuildContext context) {
    return Material(
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
                  if (icon != null) icon!,
                  if (icon != null) const SizedBox(width: 5),
                  if (title != null) title!,
                ],
              ),
            ),
          ),
        ),
        _buildWindowButtons(context),
      ],
    );
  }

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
          hoverColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: actions!,
      ),
    );
  }
}

class MexanydPageButton extends StatelessWidget {
  final String text1;
  final String? text2;
  final IconData icon;
  final void Function()? onPressed;

  const MexanydPageButton({
    super.key,
    required this.text1,
    required this.onPressed,
    required this.icon,
    this.text2,
  });

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

  Widget _buildText(BuildContext context) {
    if (text2 == null) {
      return Text(text1, style: const TextStyle(fontSize: 12));
    } else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Entrada", style: TextStyle(fontSize: 10)),
          Text("Saída", style: TextStyle(fontSize: 10)),
        ],
      );
    }
  }

  Widget _buildIcon(BuildContext context) {
    if (text2 == null) {
      return Icon(icon, size: 32);
    } else {
      return Icon(icon, size: 20);
    }
  }

  ButtonStyle _generateStyle(BuildContext context) {
    return TextButton.styleFrom(
      disabledBackgroundColor: Theme.of(context).colorScheme.primary,
      disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.background,
      foregroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class WindowButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget icon;
  final Color? hoverColor;

  const WindowButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      iconSize: 20,
      hoverColor: hoverColor,
    );
  }
}

class MaximizeButton extends StatefulWidget {
  final Color? hoverColor;

  const MaximizeButton({super.key, this.hoverColor});

  @override
  State<MaximizeButton> createState() => _MaximizeButtonState();
}

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
