import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/constants/app_colors.dart';
import 'package:pos/data/models/cart_item_model.dart';
import 'package:pos/data/models/order_model.dart';
import 'package:pos/presentation/cubits/order_cubit.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final Order order;
  final List<CartItem> items;

  const ReceiptPreviewScreen({
    super.key,
    required this.order,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final currencyFormat = NumberFormat.simpleCurrency();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'تم الطلب بنجاح',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            _finishOrder(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 10),
            const Text(
              'تمت العملية بنجاح',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Visual Receipt Card
            Container(
              width: 350, // Fixed width like a paper receipt
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                   const Text(
                    'POS System',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    dateFormat.format(order.orderDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Divider(height: 30, thickness: 1),
                  
                  // Items Table
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(1), 
                      2: FlexColumnWidth(2),
                    },
                    children: [
                      const TableRow(
                        children: [
                          Text('الصنف', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('عدد', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('سعر', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const TableRow(children: [SizedBox(height: 10), SizedBox(height: 10), SizedBox(height: 10)]),
                      ...items.map((item) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(item.product.name),
                          ),
                          Text('${item.quantity}', textAlign: TextAlign.center),
                          Text(currencyFormat.format(item.total), textAlign: TextAlign.right),
                        ],
                      )),
                    ],
                  ),
                  
                  const Divider(height: 30, thickness: 1),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المجموع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        currencyFormat.format(order.totalAmount),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  const Text('شكراً لزيارتكم', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20), // Space for "paper tear" effect
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () => _finishOrder(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'طلب جديد',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _finishOrder(BuildContext context) {
    context.read<OrderCubit>().startNewOrder();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

