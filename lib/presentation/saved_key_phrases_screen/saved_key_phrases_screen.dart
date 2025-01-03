import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/saved_key_phrases_screen/saved_key_phrases_view_model.dart';
import 'package:provider/provider.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';

class SavedKeyPhrasesScreen extends StatelessWidget {
  const SavedKeyPhrasesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          _Header(),
          Expanded(child: _KeyPhrasesTableWidget()),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        "Ключевые фразы",
        style: TextStyle(
          fontSize: theme.textTheme.titleLarge?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _KeyPhrasesTableWidget extends StatefulWidget {
  const _KeyPhrasesTableWidget({Key? key}) : super(key: key);

  @override
  State<_KeyPhrasesTableWidget> createState() => _KeyPhrasesTableWidgetState();
}

class _KeyPhrasesTableWidgetState extends State<_KeyPhrasesTableWidget> {
  final tableViewController = TableViewController();

  @override
  void dispose() {
    tableViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SavedKeyPhrasesViewModel>();
    final theme = Theme.of(context);

    final phrases = model.keyPhrases;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 600;

        final double colWidth = isMobile ? maxWidth - 16 : maxWidth - 32;

        final columns = <TableColumn>[
          TableColumn(width: colWidth),
        ];

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TableView.builder(
                  controller: tableViewController,
                  columns: columns,
                  rowHeight: model.tableRowHeight,
                  rowCount: phrases.length,
                  headerBuilder: (context, contentBuilder) {
                    return contentBuilder(context, (ctx, colIndex) {
                      return _buildHeaderCell(context, "Поисковые запросы");
                    });
                  },
                  rowBuilder: (context, rowIndex, contentBuilder) {
                    final item = phrases[rowIndex];
                    return contentBuilder(context, (ctx, colIndex) {
                      return _buildPhraseCell(context, item);
                    });
                  },
                ),
              ),
            ),
            Positioned(
              left: 26,
              top: 26,
              child: Text(
                "Всего фраз: ${phrases.length}",
                style: TextStyle(
                  fontSize: theme.textTheme.bodyMedium?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: theme.textTheme.bodyMedium?.fontSize,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPhraseCell(BuildContext context, KeyPhrase item) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(item.phraseText),
    );
  }
}
