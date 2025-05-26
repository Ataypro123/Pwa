import 'package:flutter/material.dart';
import 'Type_of_return/ManualReturnPage.dart';
import 'Type_of_return/ReceiptReturnPage.dart';

class ReturnGoodsPage extends StatelessWidget {
  
  const ReturnGoodsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор типа возврата'),
        backgroundColor: Colors.blueGrey[800],
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildReturnOption(
              context,
              title: 'Возврат по чеку',
              description: 'Вернуть товар по номеру чека.',
              icon: Icons.receipt_long,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReceiptReturnPage()),
                );
              },
            ),
            const SizedBox(height: 20.0),
            _buildReturnOption(
              context,
              title: 'Ручной возврат',
              description: 'Добавить товар вручную.',
              icon: Icons.edit_note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManualReturnPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnOption(BuildContext context,
      {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40.0, color: Colors.blueGrey[700]),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 20.0, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}