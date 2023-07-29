import 'dart:io';
import 'package:path/path.dart';


bool isNumber(String? string) {
  // Null or empty string is not a number
  if (string == null || string.isEmpty) {
    return false;
  }
  // Try to parse input string to number.
  // Both integer and double work.
  // Use int.tryParse if you want to check integer only.
  // Use double.tryParse if you want to check double only.
  // final number = num.tryParse(string);
  final number = int.tryParse(string);
  if (number == null) {
    return false;
  }
  return true;
}

bool isPlatformAndroid()  {
  return Platform.isAndroid;
}

bool isPlatformIos()  {
  return Platform.isIOS;
}
