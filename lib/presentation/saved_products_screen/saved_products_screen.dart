import 'package:flutter/material.dart';
import 'package:mc_dashboard/domain/entities/saved_product.dart';
import 'package:mc_dashboard/presentation/saved_products_screen/saved_products_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_table_view/material_table_view.dart';

import 'package:url_launcher/url_launcher.dart';

class SavedProductsScreen extends StatelessWidget {
  const SavedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceContainerHighest = theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const _Header(),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  height: constraints.maxHeight * 0.9,
                  child: const _SavedTableWidget(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Выбранные товары",
            style: TextStyle(
              fontSize: theme.textTheme.titleLarge!.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SavedTableWidget extends StatefulWidget {
  const _SavedTableWidget({Key? key}) : super(key: key);

  @override
  State<_SavedTableWidget> createState() => _SavedTableWidgetState();
}

class _SavedTableWidgetState extends State<_SavedTableWidget> {
  final tableViewController = TableViewController();

  @override
  void dispose() {
    tableViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SavedProductsViewModel>();
    final theme = Theme.of(context);

    final savedList = model.savedProducts;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final maxHeight = constraints.maxHeight;

              final isMobile = (maxWidth < 600) && (maxHeight < 690);

              final mobileMinColumnWidths = [
                50.0,
                200.0,
                150.0,
                150.0,
              ];

              final columnProportions = [
                0.08,
                0.35,
                0.28,
                0.29,
              ];

              final columnWidths = isMobile
                  ? mobileMinColumnWidths
                  : columnProportions.map((p) => p * maxWidth).toList();

              final columns = <TableColumn>[
                TableColumn(width: columnWidths[0]),
                TableColumn(width: columnWidths[1]),
                TableColumn(width: columnWidths[2]),
                TableColumn(width: columnWidths[3]),
              ];

              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TableView.builder(
                        controller: tableViewController,
                        columns: columns,
                        rowHeight: model.tableRowHeight,
                        rowCount: savedList.length,
                        headerBuilder: (context, contentBuilder) {
                          return contentBuilder(context,
                              (context, columnIndex) {
                            switch (columnIndex) {
                              case 0:
                                return const SizedBox();
                              case 1:
                                return _buildHeaderCell(context, "Товар");
                              case 2:
                                return _buildHeaderCell(context, "Продавец");
                              case 3:
                                return _buildHeaderCell(context, "Бренд");
                              default:
                                return const SizedBox();
                            }
                          });
                        },
                        rowBuilder: (context, rowIndex, contentBuilder) {
                          final item = savedList[rowIndex];
                          return KeyedSubtree(
                            key: ValueKey<int>(item.productId),
                            child: _SavedTableRow(
                              model: model,
                              item: item,
                              contentBuilder: contentBuilder,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 26,
                    top: 26,
                    child: Text(
                      "Всего сохранённых товаров: ${savedList.length}",
                      style: TextStyle(
                        fontSize: theme.textTheme.bodyMedium!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (model.selectedRows.isNotEmpty)
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: SpeedDial(
                        icon: Icons.more_vert,
                        activeIcon: Icons.close,
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        onClose: () {
                          setState(() {
                            model.selectedRows.clear();
                          });
                        },
                        children: [
                          SpeedDialChild(
                            backgroundColor: theme.colorScheme.secondary,
                            child: Icon(
                              Icons.delete,
                              color: theme.colorScheme.onSecondary,
                            ),
                            label: "Убрать из сохранённых",
                            onTap: () {
                              model.removeProductsFromSaved(model.selectedRows);
                              setState(() {
                                model.selectedRows.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: theme.textTheme.bodyMedium!.fontSize,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SavedTableRow extends StatelessWidget {
  final SavedProductsViewModel model;
  final SavedProduct item;
  final Widget Function(
    BuildContext,
    Widget Function(BuildContext, int columnIndex),
  ) contentBuilder;

  const _SavedTableRow({
    Key? key,
    required this.model,
    required this.item,
    required this.contentBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return contentBuilder(context, (context, columnIndex) {
      switch (columnIndex) {
        case 0:
          return _CheckboxCell(productId: item.productId);

        case 1:
          return _ProductCell(item: item);

        case 2:
          return _TextCell(text: item.sellerName);

        case 3:
          return _TextCell(text: item.brandName);

        default:
          return const SizedBox();
      }
    });
  }
}

class _CheckboxCell extends StatelessWidget {
  final int productId;
  const _CheckboxCell({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<SavedProductsViewModel, bool>(
      selector: (_, vm) => vm.selectedRows.contains(productId),
      builder: (context, isSelected, child) {
        return Container(
          alignment: Alignment.center,
          child: Checkbox(
            checkColor: theme.colorScheme.secondary,
            activeColor: Colors.transparent,
            side: WidgetStateBorderSide.resolveWith(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return const BorderSide(color: Colors.transparent);
                }
                return BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(.3),
                  width: 2.0,
                );
              },
            ),
            value: isSelected,
            onChanged: (bool? value) {
              context.read<SavedProductsViewModel>().selectRow(productId);
            },
          ),
        );
      },
    );
  }
}

class _TextCell extends StatelessWidget {
  final String text;
  const _TextCell({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(text),
    );
  }
}

class _ProductCell extends StatelessWidget {
  final SavedProduct item;
  const _ProductCell({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    final productName = item.name;
    final wildberriesUrl =
        "https://wildberries.ru/catalog/${item.productId}/detail.aspx?targetUrl=EX";

    if (imageUrl.isEmpty) {
      return Row(
        children: [
          Image.asset('images/no_image.jpg', width: 50),
          const SizedBox(width: 8),
          productName.isEmpty
              ? const Text("Описание отсутствует")
              : Text(productName),
        ],
      );
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (imageUrl.isNotEmpty) {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: InteractiveViewer(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text('Ошибка загрузки изображения'),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return const SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
          child: Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('images/no_image.jpg', width: 50);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return const SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => launchUrl(Uri.parse(wildberriesUrl)),
              child: Text(
                productName.isEmpty ? "Без названия" : productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF5166e3),
                  color: Color(0xFF5166e3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
