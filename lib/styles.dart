import 'package:flutter/material.dart';

final app_theme = ThemeData.from(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.dark,
    ));

final all_text_color = app_theme.colorScheme.primary;
final background_color = app_theme.colorScheme.onPrimary;
final container_color = app_theme.colorScheme.primaryContainer;
final container_border_color = app_theme.colorScheme.onPrimaryFixed;
final button_style = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll<Color>(container_color));
final invalid_cell_container_color = Colors.redAccent.shade700;
final invalid_cell_color = app_theme.colorScheme.onPrimaryFixed;
final pre_filled_cell_color = Colors.greenAccent.shade700;

bool styles_initialized = false;
late final TextStyle title_text_style;
late final TextStyle body_text_style;
late final TextStyle invalid_cell_text_style;
late final TextStyle pre_filled_cell_text_style;

void create_styles(ThemeData app_theme) {
  // some how the above defined app_theme and this app_theme is different
  if (!styles_initialized) {
    title_text_style =
        app_theme.textTheme.displayLarge!.copyWith(color: all_text_color);

    body_text_style =
        app_theme.textTheme.headlineLarge!.copyWith(color: all_text_color);

    invalid_cell_text_style =
        body_text_style.copyWith(color: invalid_cell_color);

    pre_filled_cell_text_style =
        body_text_style.copyWith(color: pre_filled_cell_color);

    styles_initialized = true;
  }
}
