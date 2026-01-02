import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubits/sales_cubit.dart';
import '../../../data/models/sales_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Load analytics data when screen opens
    context.read<SalesCubit>().loadSalesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليلات المبيعات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SalesCubit>().refresh();
            },
          ),
        ],
      ),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SalesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'خطأ في تحميل البيانات',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SalesCubit>().refresh();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is SalesLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<SalesCubit>().refresh(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    if (state.summary != null) ...[
                      _buildSummarySection(context, state.summary!),
                      const SizedBox(height: 24),
                    ],

                    // Top Products
                    if (state.topProducts.isNotEmpty) ...[
                      _buildSectionTitle(context, 'أكثر المنتجات مبيعاً'),
                      const SizedBox(height: 12),
                      _buildTopProductsList(context, state.topProducts),
                      const SizedBox(height: 24),
                    ],

                    // Daily Sales Chart
                    if (state.dailySales.isNotEmpty) ...[
                      _buildSectionTitle(context, 'المبيعات اليومية'),
                      const SizedBox(height: 12),
                      _buildDailySalesChart(context, state.dailySales),
                    ],
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, SalesSummary summary) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفترة: ${dateFormat.format(summary.startDate)} - ${dateFormat.format(summary.endDate)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'إجمالي المبيعات',
                '\$${summary.totalSales.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'عدد الطلبات',
                summary.totalOrders.toString(),
                Icons.receipt_long,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          context,
          'إجمالي المنتجات المباعة',
          summary.totalItems.toString(),
          Icons.shopping_cart,
          Colors.orange,
        ),
        
        // Sales by Category
        if (summary.salesByCategory.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle(context, 'المبيعات حسب الفئة'),
          const SizedBox(height: 12),
          ...summary.salesByCategory.map((category) => 
            _buildCategoryCard(context, category)
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, SalesByCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.category),
        title: Text(category.categoryName),
        subtitle: Text('الكمية: ${category.totalQuantity}'),
        trailing: Text(
          '\$${category.totalRevenue.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildTopProductsList(BuildContext context, List<TopProduct> products) {
    return Column(
      children: products.map((product) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '${products.indexOf(product) + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(product.productName),
            subtitle: Text('الكمية المباعة: ${product.totalQuantity}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${product.totalRevenue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailySalesChart(BuildContext context, List<DailySales> sales) {
    final maxSales = sales.map((s) => s.totalSales).reduce((a, b) => a > b ? a : b);
    final dateFormat = DateFormat('dd/MM');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sales.map((daily) {
            final percentage = daily.totalSales / maxSales;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(daily.date),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${daily.totalSales.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${daily.orderCount} طلب',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
