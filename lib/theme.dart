import 'package:flutter/material.dart';

/// Returns the background color based on the theme.
Color? listBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.grey[900]
      : Colors.grey[300];
}

/// Generates the light theme using the Material 3 design as a base.
ThemeData lightTheme() {
  var baseTheme = ThemeData.light(useMaterial3: true);

  return baseTheme.copyWith(
    primaryColor: Colors.blue[700],
    colorScheme: baseTheme.colorScheme.copyWith(
      primary: Colors.blue[700],
      onPrimary: Colors.white,
    ),
  );
}

/// Generates the dark theme using the Material 3 design as a base.
ThemeData darkTheme() {
  var baseTheme = ThemeData.dark(useMaterial3: true);

  return baseTheme.copyWith(
    primaryColor: Colors.blue,
    colorScheme: baseTheme.colorScheme.copyWith(
      primary: Colors.blue,
      background: Colors.black,
      surface: Colors.transparent,
      surfaceVariant: Colors.grey[900],
      onPrimary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white,
    ),
  );
}

/// Returns the border for the text field.
InputBorder textFieldBorder(BuildContext context) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
  );
}
