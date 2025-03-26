import 'package:flutter/material.dart';

abstract class ViewModelBase extends ChangeNotifier {
  final BuildContext context;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ViewModelBase({required this.context});

  void setLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void setLoaded() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> asyncInit();
}
