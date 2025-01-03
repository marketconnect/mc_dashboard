import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';

class MailingSettingsViewModel extends ViewModelBase {
  MailingSettingsViewModel({required super.context});

  // Fields ////////////////////////////////////////////////////////////////////
  // Checkboxes
  bool _positionsCheckbox = false;
  bool get positionsCheckbox => _positionsCheckbox;

  bool _pricesCheckbox = false;
  bool get pricesCheckbox => _pricesCheckbox;

  bool _changesCheckbox = false;
  bool get changesCheckbox => _changesCheckbox;

  bool _missedQueriesCheckbox = false;
  bool get missedQueriesCheckbox => _missedQueriesCheckbox;
  List<String> _emails = [];
  List<String> get emails => _emails;

  // Setters ///////////////////////////////////////////////////////////////////

  void setPositionsCheckbox(bool value) {
    _positionsCheckbox = value;
    notifyListeners();
  }

  void setPricesCheckbox(bool value) {
    _pricesCheckbox = value;
    notifyListeners();
  }

  void setChangesCheckbox(bool value) {
    _changesCheckbox = value;
    notifyListeners();
  }

  void setMissedQueriesCheckbox(bool value) {
    _missedQueriesCheckbox = value;
    notifyListeners();
  }

  // Methods ///////////////////////////////////////////////////////////////////

  void addEmail(String email) {
    _emails.add(email);
    notifyListeners();
  }

  void removeEmail(String email) {
    _emails.remove(email);
    notifyListeners();
  }
}
