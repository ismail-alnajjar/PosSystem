import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/constants/app_colors.dart';
import 'package:pos/data/models/order_model.dart';
import 'package:pos/presentation/cubits/order_cubit.dart';
import 'package:pos/presentation/cubits/orders_history_cubit.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersHistoryCubit>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الطلبات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<OrdersHistoryCubit, OrdersHistoryState>(
        builder: (context, state) {
          if (state is OrdersHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrdersHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.error_outline, size: 64, color: Colors.red),
                   const SizedBox(height: 16),
                   Text('خطأ: ${state.message}'),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () => context.read<OrdersHistoryCubit>().loadOrders(),
                     child: const Text('إعادة المحاولة'),
                   ),
                ],
              ),
            );
          }

          if (state is OrdersHistoryLoaded) {
            if (state.orders.isEmpty) {
              return const Center(child: Text('لا يوجد طلبات سابقة'));
            }

            final totalAmount = state.orders.fold<double>(
              0,
              (sum, order) => sum + order.totalAmount,
            );
            final formatCurrency = NumberFormat.simpleCurrency();

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إجمالي الطلبات:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatCurrency.format(totalAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.orders.length,
                    itemBuilder: (context, index) {
                      final order = state.orders[index];
                      return _OrderCard(order: order);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency();
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب #${order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy hh:mm a').format(order.orderDate),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  formatCurrency.format(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.itemCount} منتجات',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _editOrder(context, order);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل الطلب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editOrder(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل الطلب'),
        content: const Text(
          'هل أنت متأكد أنك تريد تعديل هذا الطلب؟\n'
          'سيتم استبدال محتويات السلة الحالية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              
              // Load order into cart
              context.read<OrderCubit>().loadOrderForEditing(order);
              
              // Go back to Home Screen (Pos Interface)
              Navigator.pop(context); 
            },
            child: const Text('تعديل'),
          ),
        ],
      ),
    );
  }
}
