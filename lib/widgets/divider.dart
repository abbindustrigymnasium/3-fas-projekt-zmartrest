import 'package:flutter/material.dart';

class VisualDivider extends StatelessWidget {
  final double height;
  final String currentTheme;

  const VisualDivider({
    super.key,
    this.height = 1,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      height: height,
      color: currentTheme == 'light' ? Colors.grey : const Color.fromARGB(255, 100, 100, 100),
    );
  }
}