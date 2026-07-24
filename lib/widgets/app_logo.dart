import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.onSurface = false});

  final double size;

  /// Kullanılmıyor artık — Ege Üniversitesi amblemi kendi zemin rengini
  /// (lacivert disk + beyaz halka) taşıdığından hangi arka plana konursa
  /// konsun okunaklı kalıyor. Geriye dönük uyumluluk için parametre duruyor.
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/ege_logo.svg',
      width: size,
      height: size,
    );
  }
}
