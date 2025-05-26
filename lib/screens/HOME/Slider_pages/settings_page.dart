import 'package:flutter/material.dart';
import '../settings_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isSimplified = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsManager.getSettings();
    setState(() {
      isSimplified = settings.isSimplified;
    });
  }

  Future<void> _toggleSimplifiedMode(bool value) async {
    final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Переключение режима'),
            content: const Text(
                'Для переключения между упрощённым и стандартным режимом необходимо перезагрузить приложение. Продолжить?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Продолжить'),
              ),
            ],
          ),
        ) ??
        false;

    if (result) {
      setState(() {
        isSimplified = value;
      });
      await SettingsManager.updateSimplifiedMode(value);

      // Показываем SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Перезагрузите приложение для применения изменений.')),
      );
    }
  }

  void _launchInstagram() async {
    const url = 'https://www.instagram.com/jojoshka_kg/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Не удалось открыть Instagram';
    }
  }

  Widget _buildSettingsCard({required IconData icon, required String title, required Widget child}) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSettingsCard(
            icon: Icons.settings,
            title: 'Режим работы',
            child: SwitchListTile(
              title: const Text('Упрощённый режим'),
              value: isSimplified,
              onChanged: _toggleSimplifiedMode,
            ),
          ),
          _buildSettingsCard(
            icon: Icons.lock,
            title: 'Сменить пароль',
            child: ListTile(
              title: const Text('Сменить пароль'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Логика смены пароля
              },
            ),
          ),
          _buildSettingsCard(
            icon: Icons.photo_camera,
            title: 'Социальные сети',
            child: ElevatedButton.icon(
              onPressed: _launchInstagram,
              icon: const Icon(Icons.photo_camera, color: Colors.white),
              label: const Text(
                'Открыть Instagram',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          _buildSettingsCard(
            icon: Icons.code,
            title: 'В разработке',
            child: const Text(
              'Здесь будут добавлены новые настройки в будущих версиях.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
