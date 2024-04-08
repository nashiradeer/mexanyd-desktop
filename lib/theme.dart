import 'package:flutter/material.dart';

Color? listBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.grey[850]
      : Colors.grey[300];
}
