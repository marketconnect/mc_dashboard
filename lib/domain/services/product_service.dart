import 'package:mc_dashboard/domain/entities/product.dart';
import 'package:mc_dashboard/presentation/add_cards_screen/add_cards_view_model.dart';

abstract class ProductSource {
  Future<List<Product>> getProducts();
}

class ProductService implements CardsService {
  final ProductSource productSource;

  const ProductService({required this.productSource});

  @override
  Future<List<Product>> fetchProducts() async {
    return await productSource.getProducts();
  }
}
