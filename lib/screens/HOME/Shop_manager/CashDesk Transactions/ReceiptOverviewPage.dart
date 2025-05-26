import 'package:flutter/material.dart';

import 'DebtorReceiptsPage.dart';
import 'ReceiptListPage.dart';
import 'ReturnHistoryPage.dart';
import 'ShiftDocumentsPage.dart';

class ReceiptOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обзор чеков'),
        backgroundColor:  const Color.fromRGBO(176, 106, 179, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              context,
              title: 'Чеки продаж',
              description: 'Просмотр и управление всеми чеками продаж.',
              icon: Icons.receipt_long,
              onTap:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptListPage()
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              title: 'Чеки возвратов',
              description: 'Просмотр и управление чеками возвратов.',
              icon: Icons.undo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReturnHistoryPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCard(context,
              title: 'Чеки должников',
              description: 'Просмотр чеков продаж, связанных с долгами.',
              icon: Icons.receipt_long,
              onTap:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DebtorReceiptsPage()
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              title: 'Документы Открытия смены',
              description: 'Просмотр и управление .',
              icon: Icons.lock_open,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShiftDocumentsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
