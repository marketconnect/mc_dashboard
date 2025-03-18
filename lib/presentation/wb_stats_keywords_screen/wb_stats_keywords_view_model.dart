import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';

import 'package:mc_dashboard/domain/entities/wb_stats_keywords.dart';

// Stats keywords service
abstract class WbStatsKeywordsWbStatsKeywordsService {
  Future<List<WbStatsKeywords>> getStatsKeywords({
    required int advertId,
    required String from,
    required String to,
  });
}

class WbStatsKeywordsViewModel extends ViewModelBase {
  WbStatsKeywordsViewModel({
    required super.context,
    required this.wbStatsKeywordsService,
  });

  final WbStatsKeywordsWbStatsKeywordsService wbStatsKeywordsService;

  List<WbStatsKeywords> _wbStatsKeywords = [];
  List<WbStatsKeywords> get wbStatsKeywords => _wbStatsKeywords;

  @override
  Future<void> asyncInit() async {
    print("Init wb stats keywords view model");
    await _fetchStatsKeywords();
    _startAutoRefresh();
  }

  Future<void> _fetchStatsKeywords() async {
    print("Fetching wb stats keywords");
    try {
      final result = await wbStatsKeywordsService.getStatsKeywords(
        advertId: 24009375,
        from: '2025-03-16',
        to: '2025-03-16',
      );
      _wbStatsKeywords = result;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    }

    notifyListeners();
  }

  void _startAutoRefresh() {
    Future.delayed(Duration(minutes: 3), () {
      _fetchStatsKeywords();
      _startAutoRefresh();
    });
  }
}
