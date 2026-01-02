import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos/data/models/cart_item_model.dart';
import 'package:pos/data/models/order_model.dart';
import 'package:pos/presentation/cubits/order_cubit.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final Order order;
  final List<CartItem> items;

  const ReceiptPreviewScreen({super.key, required this.order, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معاينة الفاتورة - تجربة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<OrderCubit>().startNewOrder();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'تم إنشاء الفاتورة بنجاح',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('رقم الطلب: ${order.id}'),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  // Generate PDF only when user clicks print
                  final pdfBytes = await _generateSimplePdf(PdfPageFormat.roll80);
                  
                  // Open Android Print Dialog directly
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfBytes,
                    name: 'Receipt_${order.id}',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error printing: $e')),
                  );
                }
              },
              icon: const Icon(Icons.print),
              label: const Text('طباعة الفاتورة الآن'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generateSimplePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final font = pw.Font.courier();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('TEST RECEIPT', style: pw.TextStyle(font: font, fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text('Order ID: ${order.id}', style: pw.TextStyle(font: font)),
                pw.SizedBox(height: 10),
                pw.Text('Total: \$${order.totalAmount}', style: pw.TextStyle(font: font)),
                pw.SizedBox(height: 20),
                // Try to print item count only
                pw.Text('Items Count: ${items.length}', style: pw.TextStyle(font: font)),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
