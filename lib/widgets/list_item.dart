import 'package:flutter/material.dart';

class MexanydListItem extends StatelessWidget {
  final IconData? icon;
  final String? top;
  final String? highlight;
  final Color? highlightColor;
  final String? description;
  final bool boldDescription;
  final Icon? buttonIcon;
  final void Function()? onClick;
  final Color? buttonColor;

  const MexanydListItem({
    this.icon,
    this.top,
    this.highlight,
    this.highlightColor,
    this.description,
    this.boldDescription = false,
    this.buttonIcon,
    this.buttonColor,
    this.onClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 60,
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (top != null)
                  Text(
                    top!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (highlight != null)
                      Text(
                        highlight!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: highlightColor,
                        ),
                      ),
                    SizedBox(width: boldDescription ? 15 : 5),
                    if (description != null)
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: boldDescription ? 20 : 18,
                          fontWeight: boldDescription
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (buttonIcon != null)
            SizedBox(
              height: 60,
              child: IconButton(
                icon: buttonIcon!,
                onPressed: onClick,
                color: Theme.of(context).colorScheme.onPrimary,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      buttonColor ?? Theme.of(context).colorScheme.primary),
                  shape: const WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
