import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../../../Data/delivery.dart';


class ItemListPage extends StatelessWidget {
  final List<DeliveryItem> items;
  final String deliveryBarcode;

  ItemListPage({required this.items, required this.deliveryBarcode});
      

  // Функция для скачивания файла
  Future<void> _downloadTxtFile(BuildContext context) async {
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
                "Штрихкод поставки:",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: boldFont),
              ),
              pw.SizedBox(height: 16),
              // Добавление штрихкода в PDF
              pw.Center(
                child: pw.BarcodeWidget(
                  data: deliveryBarcode,
                  barcode: pw.Barcode.code128(),
                  width: 200,
                  height: 80,
                  drawText: true,
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Text(
                "Список товаров:\n",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: boldFont),
              ),
              pw.SizedBox(height: 16),
              pw.Column(
                children: items.map((item) {
                  return pw.Text(
                    'Название: ${item.name}, Цена: ${item.price}, Количество: ${item.quantity}, Цена2: ${item.price2}\n',
                    style: pw.TextStyle(fontSize: 14, font: font),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Печать или сохранение PDF
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список товаров'),
        backgroundColor: const Color.fromRGBO(69, 104, 220, 1)      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Штрихкод поставки:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Отображение штрихкода
            BarcodeWidget(
              data: deliveryBarcode,
              barcode: Barcode.code128(), // Тип штрихкода
              width: 300,
              height: 100,
              drawText: true, // Показывать текст под штрихкодом
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Количество: ${item.quantity}'),
                    trailing: Text('Цена: ${item.price}'),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _downloadTxtFile(context);
        },
        child: Icon(Icons.print),
        tooltip: 'Печать',
      ),
    );
  }
}
