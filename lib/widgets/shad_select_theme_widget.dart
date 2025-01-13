import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/util/app_utils.dart';

class ShadSelectThemeWidget extends StatelessWidget {
  final ValueChanged<String> onThemeChanged;
  final String initialValue;

  const ShadSelectThemeWidget({
    Key? key,
    required this.onThemeChanged,
    required this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShadSelect(
      initialValue: initialValue,
      maxHeight: 200,
      minWidth: MediaQuery.of(context).size.width - 60,
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