import 'package:flutter/material.dart';
import 'Finance/FinanceOverPage.dart';
import 'Showcase/OpenedDeliveryPage.dart';
import '../../../../Data/delivery.dart';
import 'CashDesk Transactions/ReceiptOverviewPage.dart';
import 'Queue of delivery/showcase.dart';

class MainPage extends StatelessWidget {
  final List<DeliveryItem> sharedItems = []; // Общий список товаров

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор страницы'),
        backgroundColor: const Color.fromRGBO(176, 106, 179, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPageCard(
              context,
              title: 'Очередь поставок',
              description: 'Просмотр всех поставок.',
              icon: Icons.list,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowcasePage(
                      onAddToSharedList: (items) {
                        sharedItems.addAll(items);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildPageCard(
              context,
              title: 'Общий список витрины',
              description: 'Просмотр товаров, добавленных из поставок.',
              icon: Icons.shopping_cart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenedDeliveryPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildPageCard(
              context,
              title: 'Кассовые Операции',
              description: 'Перейти на страницу кассовых операций для работы с документами.',
              icon: Icons.work,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  ReceiptOverviewPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildPageCard(
              context,
              title: 'Финансы',
              description: 'Перейти на страницу Финасов для работы с документами.',
              icon: Icons.money,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  FinanceOverPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Colors.blueAccent),
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
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
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
