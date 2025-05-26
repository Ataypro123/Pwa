import 'package:flutter/material.dart';

class JojosMarketPage extends StatelessWidget {
  const JojosMarketPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 49, 183),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          'JOJOS MARKET',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите ваш план:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPlanCard(
                    context,
                    title: 'Jojos Starter',
                    description: 'Идеальный план для новичков с базовыми возможностями.',
                    icon: Icons.start,
                    color: Colors.blueGrey[700]!,
                  ),
                  const SizedBox(height: 16.0),
                  _buildPlanCard(
                    context,
                    title: 'Jojos Pro',
                    description: 'Расширенные функции для опытных пользователей.',
                    icon: Icons.star,
                    color: Colors.teal[700]!,
                  ),
                  const SizedBox(height: 16.0),
                  _buildPlanCard(
                    context,
                    title: 'Jojos Premium',
                    description: 'Максимальные возможности и приоритетная поддержка.',
                    icon: Icons.verified_user,
                    color: Colors.blueAccent[700]!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Общий вид карточки тарифа
  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        _navigateToDetails(context, title, description);
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Colors.white),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 20.0, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  // Метод для перехода на детальную страницу
  void _navigateToDetails(BuildContext context, String title, String description) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: animation,
        child: PlanDetailsScreen(title: title, description: description),
      ),
    ));
  }
}

class PlanDetailsScreen extends StatelessWidget {
  final String title;
  final String description;

  const PlanDetailsScreen({Key? key, required this.title, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 80.0, color: Colors.blueAccent[700]),
            const SizedBox(height: 24.0),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16.0,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent[700],
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Назад',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
