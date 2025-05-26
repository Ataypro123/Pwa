import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Отчеты"),
        backgroundColor: const Color.fromRGBO(69, 104, 220, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildReportButton(
              context,
              title: "Отчеты по видам продаж",
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalesReportPage(),
                  ),
                );
              },
            ),
            _buildReportButton(
              context,
              title: "Отчет по должникам",
              icon: Icons.warning,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DebtorsReportPage(),
                  ),
                );
              },
            ),
            _buildReportButton(
              context,
              title: "Отчет по принятым поставкам",
              icon: Icons.local_shipping,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveriesReportPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportButton(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}

class SalesReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Пример страницы с отчетами по видам продаж
    return Scaffold(
      appBar: AppBar(
        title: Text("Отчеты по видам продаж"),
        backgroundColor: const Color.fromRGBO(69, 104, 220, 1),
      ),
      body: Center(
        child: Text(
          "Данные по продажам по видам",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class DebtorsReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Пример страницы с отчетами по должникам
    return Scaffold(
      appBar: AppBar(
        title: Text("Отчет по должникам"),
        backgroundColor: const Color.fromRGBO(69, 104, 220, 1),
      ),
      body: Center(
        child: Text(
          "Данные по должникам",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class DeliveriesReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Пример страницы с отчетами по принятым поставкам
    return Scaffold(
      appBar: AppBar(
        title: Text("Отчет по принятым поставкам"),
        backgroundColor: const Color.fromRGBO(69, 104, 220, 1),
      ),
      body: Center(
        child: Text(
          "Данные по принятым поставкам",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
