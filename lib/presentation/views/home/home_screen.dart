import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/constants/app_colors.dart';
import 'package:pos/presentation/cubits/order_cubit.dart';
import 'package:pos/presentation/views/history/orders_history_screen.dart';

import 'widgets/category_panel.dart';
import 'widgets/order_summary.dart';
import 'widgets/product_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we are on a wide screen (Tablet/Desktop)
        final isWideScreen = constraints.maxWidth > 900;

        if (isWideScreen) {
          return _buildTabletLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildTopBar(context),
                const CategoryPanel(),
                const Expanded(child: ProductGrid()),
              ],
            ),
          ),
          const SizedBox(width: 400, child: OrderSummary()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'POS',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersHistoryScreen(),
                ),
              );
            },
            tooltip: 'سجل الطلبات',
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.accent,
            ),
            onPressed: () => _showMobileCart(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const CategoryPanel(),
          const Expanded(child: ProductGrid()),
        ],
      ),
      floatingActionButton: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is! OrderInProgress || state.items.isEmpty) {
            return const SizedBox.shrink();
          }

          final formatCurrency = NumberFormat.simpleCurrency();
          return FloatingActionButton.extended(
            onPressed: () => _showMobileCart(context),
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              '${state.items.length} Items • ${formatCurrency.format(state.totalAmount)}',
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.point_of_sale, size: 30, color: AppColors.accent),
          ),
          Text(
            'POS',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersHistoryScreen(),
                ),
              );
            },
            tooltip: 'سجل الطلبات',
          ),
        ],
      ),
    );
  }

  void _showMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(child: OrderSummary(scrollController: controller)),
              ],
            ),
          );
        },
      ),
    );
  }
}
