import 'package:flutter/material.dart';
import 'package:mc_dashboard/domain/entities/wb_stats_keywords.dart';
import 'package:mc_dashboard/presentation/wb_stats_keywords_screen/wb_stats_keywords_view_model.dart';
import 'package:provider/provider.dart';

class WbStatsKeywordsScreen extends StatefulWidget {
  const WbStatsKeywordsScreen({Key? key});

  @override
  State<WbStatsKeywordsScreen> createState() => _WbStatsKeywordsScreenState();
}

class _WbStatsKeywordsScreenState extends State<WbStatsKeywordsScreen> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<WbStatsKeywordsViewModel>();
    final keywordsList = model.wbStatsKeywords;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFE8ECF4),
                      offset: Offset(0, 1),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF1E232C)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Keyword Statistics',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF1E232C),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF1E232C)),
                      onPressed: () {
                        // Handle search
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE8ECF4),
                              width: 1.0,
                            ),
                          ),
                          child: _buildKeywordsTable(keywordsList),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeywordsTable(List<WbStatsKeywords> keywordsList) {
    if (keywordsList.isEmpty) {
      return const Center(child: Text('Нет данных для отображения'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
            const Color(0xFFF7F7F7)), // Subtle grey header
        dataRowHeight: 50,
        dividerThickness: 1.0,
        columns: const [
          DataColumn(
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text('Ключевое слово',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF1E232C))),
            ),
          ),
          DataColumn(
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text('Клики',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF1E232C))),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text('CTR',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF1E232C))),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text('Сумма',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF1E232C))),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text('Просмотры',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF1E232C))),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text('Удалить',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF1E232C))),
            ),
          ),
        ],
        rows: keywordsList.map((keyword) {
          return DataRow(
            cells: [
              DataCell(Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(keyword.keyword,
                    style: const TextStyle(color: Color(0xFF1E232C))),
              )),
              DataCell(Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(keyword.clicks.toString(),
                    style: const TextStyle(color: Color(0xFF1E232C))),
              )),
              DataCell(Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text('${keyword.ctr.toStringAsFixed(2)}%',
                    style: const TextStyle(color: Color(0xFF1E232C))),
              )),
              DataCell(Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text('${keyword.sum.toStringAsFixed(2)} ₽',
                    style: const TextStyle(color: Color(0xFF1E232C))),
              )),
              DataCell(Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(keyword.views.toString(),
                    style: const TextStyle(color: Color(0xFF1E232C))),
              )),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF1E232C)),
                  onPressed: () {
                    // Ваш код для удаления ключевого слова
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
