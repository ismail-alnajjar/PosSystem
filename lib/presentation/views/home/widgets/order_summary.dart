import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/constants/app_colors.dart';
import 'package:pos/data/models/cart_item_model.dart';
import 'package:pos/data/models/order_model.dart'; // Import Order
import 'package:pos/data/services/qz_tray_service.dart'; // Import Service
import 'package:pos/presentation/cubits/order_cubit.dart';
import 'package:pos/presentation/views/receipt/receipt_preview_screen.dart';

class OrderSummary extends StatefulWidget {
  final ScrollController? scrollController;

  const OrderSummary({super.key, this.scrollController});

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  late final QzTrayService _qzTrayService;
  // ignore: unused_field
  String? _selectedPrinter;

  @override
  void initState() {
    super.initState();
    _qzTrayService = QzTrayService();
    _initPrinter();
  }

  Future<void> _initPrinter() async {
    final connected = await _qzTrayService.connect();
    if (connected) {
      // Listen for printer list response
      _qzTrayService.onMessage.listen((data) {
        // Simple logic to pick a printer from response if applicable
        // valid response handling depends on QZ version.
        // For now we assume the user has a printer named "POS-80" or uses default.
        if (data.containsKey('printers')) {
          // Handle printer list
        }
      });
      // Trigger find
      _qzTrayService.findPrinters();
    }
  }

  @override
  void dispose() {
    _qzTrayService.dispose();
    super.dispose();
  }

  String _generateReceiptHtml(Order order, List<CartItem> items) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(order.orderDate);

    // Generate Items Rows
    String itemsHtml = '';
    for (var item in items) {
      itemsHtml +=
          '''
        <tr>
          <td style="padding: 5px 0; text-align: right;">${item.product.name}</td>
          <td style="text-align: center;">${item.quantity}</td>
          <td style="text-align: left;">${item.total.toStringAsFixed(2)}</td>
        </tr>
      ''';
    }

    return '''
      <html dir="rtl" lang="ar">
      <head>
        <meta charset="UTF-8">
        <style>
          body { 
            font-family: 'Tahoma', 'Arial', sans-serif; 
            font-size: 12px; 
            width: 100%; 
            margin: 0; 
            padding: 0; 
            background-color: #fff;
          }
          .header { text-align: center; margin-bottom: 10px; }
          .header h2 { margin: 0; font-size: 16px; font-weight: bold; }
          .header p { margin: 2px 0; font-size: 12px; }
          
          table { width: 100%; border-collapse: collapse; margin-top: 10px; }
          th { border-bottom: 1px dashed #000; padding: 5px 0; font-weight: bold; font-size: 12px; }
          td { padding: 5px 0; vertical-align: top; font-size: 12px; }
          
          .totals { border-top: 1px dashed #000; margin-top: 10px; padding-top: 5px; }
          .footer { text-align: center; margin-top: 20px; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="header">
          <h2>نظام نقاط البيع</h2>
          <p>طلب رقم #${order.id}</p>
          <p>$formattedDate</p>
        </div>
        
        <table>
          <thead>
            <tr>
              <th style="text-align: right; width: 45%;">الصنف</th>
              <th style="text-align: center; width: 20%;">العدد</th>
              <th style="text-align: left; width: 35%;">السعر</th>
            </tr>
          </thead>
          <tbody>
            $itemsHtml
          </tbody>
        </table>

        <div class="totals">
          <div style="display: flex; justify-content: space-between; font-weight: bold; font-size: 14px;">
            <span>المجموع</span>
            <span>${order.totalAmount.toStringAsFixed(2)}</span>
          </div>
        </div>
        
        <div class="footer">
          <p>شكرًا لزيارتكم!</p>
        </div>
      </body>
      </html>
    ''';
  }

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
                  // Print Receipt
                  // Use a specific printer name or default
                  // Ensure you update 'Reference POS' to your actual printer name
                  _qzTrayService.printHtmlReceipt(
                    "Reference POS",
                    _generateReceiptHtml(state.order, state.items),
                  );

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
                  controller: widget.scrollController,
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
