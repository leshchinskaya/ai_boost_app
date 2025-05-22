import 'package:flutter/material.dart';

class TestProvider with ChangeNotifier {
  AppState<dynamic> _widget = AppState();
  AppState<dynamic> get widget => _widget;
  void _setState(AppState<dynamic> state) {
    _widget = state;
    notifyListeners();
  }
  void get() async {
    
  }
}