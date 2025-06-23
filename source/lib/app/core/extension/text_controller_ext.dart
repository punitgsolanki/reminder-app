import 'package:flutter/material.dart';

extension TextControllerExt on TextEditingController {
  String get getString => text.toString().trim();

  bool get isEmpty => text.toString().trim().isEmpty;
}