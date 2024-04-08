import 'package:flutter/material.dart';

class MexanydPage extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;

  const MexanydPage({super.key, this.title, required this.child, this.actions});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          if (actions != null)
            Container(
              padding: const EdgeInsets.all(5),
              child: Column(children: actions!),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class MexanydPageButton extends StatelessWidget {
  final Widget label;
  final Widget icon;
  final void Function()? onPressed;
  final double height;
  final double width;
  final ButtonStyle? style;

  const MexanydPageButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.style,
    this.height = 65,
    this.width = 65,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Expanded(
        child: TextButton(
          onPressed: onPressed,
          style: style ?? _generateStyle(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              label,
            ],
          ),
        ),
      ),
    );
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
  @override
  Widget build(BuildContext context) {
    return const Material();
  }
}
