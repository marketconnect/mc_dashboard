// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/normquery.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class SeoRequestsExtendNormqueryService {
  Future<Either<AppErrorBase, List<Normquery>>> getUniqueNormqueries(
      {required List<int> ids});
}

abstract class SeoRequestsExtendAuthService {
  Future<Either<AppErrorBase, Map<String, String?>>> getTokenAndType();
  String? getPaymentUrl();
  logout();
}

class SeoRequestsExtendViewModel extends ViewModelBase {
  SeoRequestsExtendViewModel({
    required super.context,
    required this.onNavigateBack,
    required this.productIds,
    required this.normqueryService,
    required this.authService,
  }) {
    _asyncInit();
  }

  final void Function() onNavigateBack;
  final List<int> productIds;
  final SeoRequestsExtendNormqueryService normqueryService;
  final SeoRequestsExtendAuthService authService;

  //  fields ///////////////////////////////////////////////////////////////////
  Map<String, String?> _tokenInfo = {};
  bool get isFree => _tokenInfo["type"] == "free";
  final List<Normquery> _normqueries = [];
  List<Normquery> get normqueries => _normqueries;

  String? _paymentUrl;
  String? get paymentUrl => _paymentUrl;

  // Table select rows
  final Set<int> _selectedRows = {};
  Set<int> get selectedRows => _selectedRows;
  bool _selectAll = false;
  bool get selectAll => _selectAll;

  // methods ///////////////////////////////////////////////////////////////////
  Future<void> _asyncInit() async {
    setLoading();
    final tokenInfoOrEither = await authService.getTokenAndType();
    if (tokenInfoOrEither.isRight()) {
      _tokenInfo = tokenInfoOrEither.fold((l) => {}, (r) => r);
    }
    if (!isFree) {
      final normqueriesEither =
          await normqueryService.getUniqueNormqueries(ids: productIds);
      if (normqueriesEither.isRight()) {
        _setNormqueries(normqueriesEither.fold((l) => [], (r) => r));
      }
    } else {
      _paymentUrl = authService.getPaymentUrl();
      _setNormqueries(generateRandomNormqueries(25));
    }
    setLoaded();
  }

  void setSelectAll(bool value) {
    _selectAll = value;
    notifyListeners();
  }

  void selectRow(int index) {
    if (_selectedRows.contains(index)) {
      _selectedRows.remove(index);
    } else {
      _selectedRows.add(index);
    }
    notifyListeners();
  }

  void selectAllMethod() {
    if (_selectedRows.isEmpty) {
      _selectedRows.addAll(List.generate(normqueries.length, (index) => index));
      _selectAll = true;
    } else {
      _selectAll = false;
      _selectedRows.clear();
    }
    notifyListeners();
  }

  void _setNormqueries(List<Normquery> value) => _normqueries.addAll(value);

  void onPaymentComplete() {
    if (paymentUrl != null) {
      launchUrl(Uri.parse(paymentUrl!));
      authService.logout();
    }
  }
}
