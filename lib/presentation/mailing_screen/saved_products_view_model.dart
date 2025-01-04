import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/saved_product.dart';

abstract class SavedProductsSavedProductsService {
  Future<Either<AppErrorBase, List<SavedProduct>>> loadProducts();
  Future<Either<AppErrorBase, void>> deleteProduct(int productId);
}

class SavedProductsViewModel extends ViewModelBase {
  SavedProductsViewModel(
      {required super.context, required this.savedProductsService});

  final SavedProductsSavedProductsService savedProductsService;

  // Fields
  final double tableRowHeight = 60.0;
  List<int> selectedRows = [];
  List<SavedProduct> _savedProducts = [];

  List<SavedProduct> get savedProducts => _savedProducts;

  // Methods
  @override
  Future<void> asyncInit() async {
    final savedProductsOrEither = await savedProductsService.loadProducts();

    if (savedProductsOrEither.isRight()) {
      _savedProducts = savedProductsOrEither.fold(
          (l) => throw UnimplementedError(), (r) => r);
    }
  }

  void removeProductsFromSaved(List<int> productIds, bool isSubscribed) {
    if (!isSubscribed) {
      return;
    }
    _savedProducts
        .removeWhere((product) => productIds.contains(product.productId));
    for (int productId in productIds) {
      savedProductsService.deleteProduct(
        productId,
      );
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
