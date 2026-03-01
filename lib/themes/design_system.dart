import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadii {
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
  static const BorderRadius button = BorderRadius.all(Radius.circular(14));
}

class AppTypography {
  static const TextStyle h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
  static const TextStyle h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w600);
  static const TextStyle body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
}
