import 'package:flutter/material.dart';

const bool isPrintLog = true;

printLog(String strLogMessage) {
  if (isPrintLog && strLogMessage.isNotEmpty) {
    debugPrint("|---> $strLogMessage");
  }
}

printExceptionLog(dynamic ex) {
  if (isPrintLog && ex != null) {
    debugPrint("| ----- ERROR ----- |");
    debugPrint("|===> ${ex.toString()}");
  }
}

class Utility {
  Utility._privateConstructor();

  static final Utility _instance = Utility._privateConstructor();

  static Utility get instance => _instance;
}