import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/promotions_screen/promotions_view_model.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Акции на ближайшие 2 недели (без автоматических)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PromotionsViewModel>().refreshData(),
          ),
        ],
      ),
      body: Consumer<PromotionsViewModel>(
        builder: (context, model, child) {
          if (model.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (model.promotions.isEmpty) {
            return const Center(child: Text("Нет доступных акций"));
          }

          // Получаем сформированные данные без вызова методов загрузки в build()
          final productData = model.promotionProductsData;
          final Set<int> productIds = productData.keys.toSet();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text("Товар")),
                ...model.promotions
                    .map((promo) => DataColumn(label: Text(promo.name))),
              ],
              rows: productIds.map((productId) {
                final basketNum = getBasketNum(productId);
                final imageUrl = calculateImageUrl(basketNum, productId);
                final cardUrl = calculateCardUrl(imageUrl);
                return DataRow(cells: [
                  DataCell(FutureBuilder<String>(
                    future:
                        fetchCardInfo(cardUrl).then((value) => value.imtName),
                    builder: (context, snapshot) {
                      final description = snapshot.data ?? "Загрузка...";
                      return Row(
                        children: [
                          Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(description)),
                        ],
                      );
                    },
                  )),
                  ...model.promotions.map((promo) {
                    final price = productData[productId]?[promo.id]?.price;
                    final priceInt = price?.toInt();
                    final discount =
                        productData[productId]?[promo.id]?.discount;
                    final discountInt = discount?.toInt();

                    final priceAfterDiscount =
                        priceInt != null && discountInt != null
                            ? (priceInt * (100 - discountInt) / 100).toInt()
                            : null;
                    // final discountPercent =
                    //     productData[productId]?[promo.id]?.planDiscount;

                    final planPrice =
                        productData[productId]?[promo.id]?.planPrice;

                    return DataCell(Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(priceAfterDiscount != null
                              ? priceAfterDiscount.toString()
                              : ""),
                          const SizedBox(width: 8),
                          Text(priceAfterDiscount != null && planPrice != null
                              ? "->"
                              : ""),
                          const SizedBox(width: 8),
                          Text(planPrice != null ? planPrice.toString() : ""),
                        ]));
                    // return DataCell(
                    //     Text(price != null ? price.toString() : "-"));
                  }),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
