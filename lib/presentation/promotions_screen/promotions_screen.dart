import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/utils/basket_num.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/promotions_screen/promotions_view_model.dart';
import 'package:mc_dashboard/domain/entities/promotions.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Акции на ближайшие 2 недели"),
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

          final Set<int> productIds = {};
          final Map<int, Map<int, PromotionNomenclature>> productData = {};

          for (var promo in model.promotions) {
            model.loadPromotionNomenclatures(promo.id);
            final nomenclatures =
                model.promotionNomenclaturesMap[promo.id] ?? [];
            for (var item in nomenclatures) {
              productIds.add(item.id);
              productData.putIfAbsent(item.id, () => {});
              productData[item.id]![promo.id] = item;
            }
          }

          // if (productIds.isEmpty) {
          //   return const Center(child: Text("Нет товаров в акциях"));
          // }

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
                    return DataCell(
                        Text(price != null ? price.toString() : "-"));
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
