import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/constants/app_colors.dart';
import 'package:pos/data/models/cart_item_model.dart';
import 'package:pos/presentation/cubits/order_cubit.dart';
import 'package:pos/presentation/views/receipt/receipt_preview_screen.dart';

class OrderSummary extends StatelessWidget {
  final ScrollController? scrollController;

  const OrderSummary({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            width: double.infinity,
            child: const Text(
              'Current Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // List
          Expanded(
            child: BlocConsumer<OrderCubit, OrderState>(
              listener: (context, state) {
                if (state is OrderSubmitted) {
                  // Navigate to Receipt Preview
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReceiptPreviewScreen(
                        order: state.order,
                        items: state.items,
                      ),
                    ),
                  );
                } else if (state is OrderError) {
                  // Show error snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: 'إعادة المحاولة',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<OrderCubit>().submitOrder();
                        },
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is OrderSubmitting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري إرسال الطلب...'),
                      ],
                    ),
                  );
                }

                final items = state is OrderInProgress
                    ? state.items
                    : (state is OrderError ? state.items : <CartItem>[]);

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items in cart',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _CartItemTile(item: items[index]);
                  },
                );
              },
            ),
          ),

          // Footer (Totals & Actions)
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              final formatCurrency = NumberFormat.simpleCurrency();

              final totalAmount = state is OrderInProgress
                  ? state.totalAmount
                  : (state is OrderError
                        ? state.items.fold<double>(
                            0,
                            (sum, item) => sum + item.total,
                          )
                        : 0.0);

              final hasItems = state is OrderInProgress
                  ? state.items.isNotEmpty
                  : (state is OrderError ? state.items.isNotEmpty : false);

              final isSubmitting = state is OrderSubmitting;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatCurrency.format(totalAmount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: hasItems && !isSubmitting
                                ? () {
                                    context.read<OrderCubit>().clearOrder();
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accentRed,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: AppColors.accentRed,
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: hasItems && !isSubmitting
                                ? () {
                                    context.read<OrderCubit>().submitOrder();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                                    child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    state is OrderInProgress &&
                                            state.editingOrderId != null
                                        ? 'تحديث الطلب'
                                        : 'إتمام الطلب',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  // ignore: unused_element_parameter
  const _CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  formatCurrency.format(item.product.price),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    context.read<OrderCubit>().decrementQuantity(item);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.read<OrderCubit>().incrementQuantity(item);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              formatCurrency.format(item.total),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.accentRed),
            onPressed: () {
              context.read<OrderCubit>().removeProduct(item.product);
            },
          ),
        ],
      ),
    );
  }
}
