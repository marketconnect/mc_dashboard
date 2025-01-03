import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/saved_product.dart';
import 'package:mc_dashboard/domain/services/saved_products_service.dart';

abstract class SavedProductsSavedProductsService {
  Future<Either<AppError, List<SavedProduct>>> loadProducts();
  Future<Either<AppError, void>> deleteProduct(int productId);
}

class SavedProductsViewModel extends ViewModelBase {
  SavedProductsViewModel(
      {required super.context, required this.savedProductsService}) {
    _asyncInit();
  }

  final SavedProductsSavedProductsService savedProductsService;

  // Fields
  final double tableRowHeight = 60.0;
  List<int> selectedRows = [];
  List<SavedProduct> _savedProducts = [];

  List<SavedProduct> get savedProducts => _savedProducts;

  // Methods
  void _asyncInit() async {
    setLoading();
    final savedProductsOrEither = await savedProductsService.loadProducts();

    if (savedProductsOrEither.isRight()) {
      _savedProducts = savedProductsOrEither.fold(
          (l) => throw UnimplementedError(), (r) => r);
    }

    setLoaded();
  }

  void removeProductsFromSaved(List<int> productIds) {
    _savedProducts
        .removeWhere((product) => productIds.contains(product.productId));
    for (int productId in productIds) {
      savedProductsService.deleteProduct(productId);
    }
    notifyListeners();
  }

  void selectRow(int productId) {
    if (selectedRows.contains(productId)) {
      selectedRows.remove(productId);
    } else {
      selectedRows.add(productId);
    }
    notifyListeners();
  }
}
