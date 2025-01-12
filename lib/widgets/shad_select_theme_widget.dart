import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

extension StringExtensions on String { 
  String capitalize() { 
    return "${this[0].toUpperCase()}${this.substring(1)}"; 
  } 
} 

class ShadSelectThemeWidget extends StatelessWidget {
  final String initialTheme;
  final ValueChanged<String> onThemeChanged;

  const ShadSelectThemeWidget({
    Key? key,
    required this.initialTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShadSelect(
      initialValue: initialTheme,
      maxHeight: 200,
      minWidth: 300,
      options: ['light', 'dark'].map(
        (option) => ShadOption(
          value: option,
          child: Text(option.capitalize()),
        ),
      ),
      selectedOptionBuilder: (context, value) {
        return Text(value.capitalize());
      },
      onChanged: (value) {
        onThemeChanged(value.toString());
      },
    );
  }
}