import 'package:flutter/material.dart';

abstract class ViewModelBase extends ChangeNotifier {
  ViewModelBase({required this.context}) {
    _initialize();
  }

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
  bool get isLoading => _loading;

  Future<void> asyncInit();

  Future<void> _initialize() async {
    try {
      setLoading();
      await asyncInit();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoaded();
    }
  }
}
