import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ZmartrestLogo extends StatelessWidget {
  final String currentTheme;
  final double width;

  const ZmartrestLogo({
    Key? key,
    this.currentTheme = 'light',
    this.width = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      currentTheme == 'light' ? 'assets/zmartrest_logo_black.svg' : 'assets/zmartrest_logo_white.svg',
      semanticsLabel: 'Zmartrest Logo',
      width: width,
    );
  }
}