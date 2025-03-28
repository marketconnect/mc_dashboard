import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_screen.dart';
import 'package:mc_dashboard/presentation/ozon_product_cards_screen/ozon_product_cards_screen.dart';

class ProductCardsContainerScreen extends StatefulWidget {
  const ProductCardsContainerScreen({super.key});

  @override
  State<ProductCardsContainerScreen> createState() =>
      _ProductCardsContainerScreenState();
}

class _ProductCardsContainerScreenState
    extends State<ProductCardsContainerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // This will trigger a rebuild and update the index
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточки товаров'),
        bottom: TabBar(
          controller: _tabController,
          automaticIndicatorColorAdjustment: false,
          indicatorColor:
              _tabController.index == 0 ? Color(0xFF9a41fe) : Color(0xFF005bff),
          tabs: [
            Tab(
              child: Text(
                'Wildberries',
                style: TextStyle(
                  color: Color(0xFF9a41fe),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Ozon',
                style: TextStyle(
                  color: Color(0xFF005bff),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProductCardsScreen(),
          OzonProductCardsScreen(),
        ],
      ),
    );
  }
}
