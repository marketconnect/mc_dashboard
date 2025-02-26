import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/add_cards_screen/add_cards_view_model.dart';
import 'package:provider/provider.dart';

class AddCardsScreen extends StatelessWidget {
  const AddCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AddCardsViewModel>();
    final products = model.products;
    final routeToProductDetail = model.routeToProductDetail;
    final errorMessage = model.error;
    print("products: $products");
    return Scaffold(
      appBar: AppBar(title: const Text("Добавить карточки товаров")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: errorMessage != null
                  ? Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    )
                  : products.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Нет доступных карточек"),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => model.loadProductsFromZip(),
                              child: const Text("Загрузить ZIP"),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final domain = Uri.parse(product.url).host;
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      Text(
                                        domain,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () => routeToProductDetail(product),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
