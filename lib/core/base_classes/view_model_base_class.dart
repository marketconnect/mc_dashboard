import 'package:flutter/material.dart';

class ViewModelBase extends ChangeNotifier {
  ViewModelBase({required this.context});
  final BuildContext context;
  late bool _loading = true;

  String? _error;
  void setLoading() {
    _loading = true;
    notifyListeners();
  }

  void setLoaded() {
    _loading = false;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  String? get error => _error;
  bool get loading => _loading;
}
