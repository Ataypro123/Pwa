import 'package:flutter/material.dart';
import '../../../../Data/receipt_item.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';


class ReceiptDetailsPage extends StatelessWidget {
  final ReturnItem receipt;

  const ReceiptDetailsPage({Key? key, required this.receipt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Детали чека №${receipt.receiptNumber}'),
        backgroundColor: Color.fromRGBO(176, 106, 179, 1),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сумма: ${receipt.totalAmount.toStringAsFixed(2)} сом',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Метод оплаты: ${receipt.paymentMethod}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Комментарий: ${receipt.comment ?? "Нет"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Список товаров:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...receipt.items.map((item) => Text(
                  '${item.name} (x${item.quantity}) - Штрихкод: ${item.barcode}',
                  style: const TextStyle(fontSize: 14),
                )),
         const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _generateAndOpenPdf(receipt);
                },
                icon: const Icon(Icons.print),
                label: const Text('Распечатать чек'),
              ),
            ),
          ],
        ),
      ),
    );
  }
/// Генерация и печать PDF копии чека
  Future<void> _generateAndOpenPdf(ReturnItem receipt) async {
    final pdf = pw.Document();

// Загрузка шрифта Roboto из встроенных ресурсов
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();



    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Чек №${receipt.receiptNumber}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: boldFont),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Метод оплаты: ${receipt.paymentMethod}',
                style: pw.TextStyle(fontSize: 14, font: font),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Комментарий: ${receipt.comment ?? "Нет"}',
                style: pw.TextStyle(fontSize: 12, font: font, color: PdfColors.grey),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Список товаров:',
                style: pw.TextStyle(fontSize: 14, font: font),
              ),
              pw.SizedBox(height: 8),
              ...receipt.items.map((item) => pw.Text(
                    '${item.name} — ${item.quantity} шт. x ${item.price.toStringAsFixed(2)} сом',
                    style: pw.TextStyle(fontSize: 12, font: font),
                  )),
              pw.SizedBox(height: 16),
              pw.Text(
                'Итого: ${receipt.totalAmount.toStringAsFixed(2)} сом',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: boldFont),
              ),
            ],
          );
        },
      ),
    );

    // Печать или сохранение PDF
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
