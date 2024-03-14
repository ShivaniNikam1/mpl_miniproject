import 'package:flutter/material.dart';

class DropdownProvider extends ChangeNotifier {
  final items = ["Grid", "List"];
  String dropdownvalue = "Grid";

  void setSelectedValue(String value) {
    dropdownvalue = value;
    notifyListeners();
  }
}
