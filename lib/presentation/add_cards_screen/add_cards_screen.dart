import 'package:flutter/material.dart';
import 'package:mc_dashboard/domain/entities/product.dart';
import 'package:mc_dashboard/presentation/add_cards_screen/add_cards_view_model.dart';
import 'package:provider/provider.dart';

class AddCardsScreen extends StatelessWidget {
  const AddCardsScreen({super.key});

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Формат Excel файла для загрузки:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(1),
              6: FlexColumnWidth(1),
              7: FlexColumnWidth(1.5),
              8: FlexColumnWidth(1.5),
            },
            children: const [
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Колонка 1\nАртикул продавца'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Колонка 2\nНазвание товара'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Колонка 3\nОписание товара'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Колонка 4\nФотографии (через ;)'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Колонка 5\nШирина'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Колонка 6\nДлина'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Колонка 7\nВысота'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Колонка 8\nВес (кг)'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Колонка 9\nСтрана происхождения'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Примечание: Первая строка в файле не должна содержать заголовков.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<ProductData> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Артикул')),
            DataColumn(label: Text('Название')),
            DataColumn(label: Text('Описание')),
            DataColumn(label: Text('Фото')),
            DataColumn(label: Text('Ширина')),
            DataColumn(label: Text('Длина')),
            DataColumn(label: Text('Высота')),
            DataColumn(label: Text('Вес (кг)')),
            DataColumn(label: Text('Страна')),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                _buildDataCell(product.id),
                _buildDataCell(product.title, maxLength: 30),
                _buildDataCell(product.description, maxLength: 50),
                _buildDataCell(product.images.length.toString() + ' фото'),
                _buildDataCell(product.width.toString()),
                _buildDataCell(product.height.toString()),
                _buildDataCell(product.length.toString()),
                _buildDataCell(product.weightKg.toString()),
                _buildDataCell(product.country),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  DataCell _buildDataCell(String value, {int? maxLength}) {
    final isEmpty = value.trim().isEmpty;
    final displayText = maxLength != null
        ? (value.length > maxLength
            ? '${value.substring(0, maxLength)}...'
            : value)
        : value;

    return DataCell(
      Tooltip(
        message: value,
        child: Text(
          displayText,
          style: TextStyle(
            color: isEmpty ? Colors.red : null,
          ),
        ),
      ),
      showEditIcon: isEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AddCardsViewModel>();
    final products = model.products;
    final errorMessage = model.error;

    return Scaffold(
      appBar: AppBar(title: const Text("Добавить карточки товаров")),
      body: Column(
        children: [
          if (products.isEmpty) _buildInstructions(),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => model.loadProductsFromExcel(),
                // model.loadProductsFromExcel(),
                child: const Text("Загрузить Excel файл"),
              ),
            ),
          if (products.isNotEmpty)
            Expanded(
              child: _buildDataTable(products),
            ),
        ],
      ),
    );
  }
}
