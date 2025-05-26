import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = 'Dzheenbekov Atay';
  String birthDate = '1995-01-01';
  String inn = '123456789';
  double scaleFactor = 1.0;

  void _editField(String field, String initialValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Изменить $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Введите $field',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _onLongPressStart() {
    setState(() => scaleFactor = 1.1); // Increase size on press start
  }

  void _onLongPressEnd() {
    setState(() => scaleFactor = 1.0); // Reset size when press ends
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Личный кабинет'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Личная информация',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Divider(),
            GestureDetector(
              onLongPress: () {
                _onLongPressStart();
                _editField('ФИО', fullName, (value) {
                  setState(() => fullName = value);
                });
                _onLongPressEnd();
              },
              child: AnimatedScale(
                scale: scaleFactor,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  "ФИО: $fullName",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onLongPress: () {
                _onLongPressStart();
                _editField('Дата рождения', birthDate, (value) {
                  setState(() => birthDate = value);
                });
                _onLongPressEnd();
              },
              child: AnimatedScale(
                scale: scaleFactor,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  "Дата рождения: $birthDate",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onLongPress: () {
                _onLongPressStart();
                _editField('ИНН', inn, (value) {
                  setState(() => inn = value);
                });
                _onLongPressEnd();
              },
              child: AnimatedScale(
                scale: scaleFactor,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  "ИНН: $inn",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const Divider(),
            Text(
              'Позиция: Владелец(Бета)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(),
            const Text(
              'Версия: Это Беспланая бета версия(Без интеграций, без поддержки, без обновлений, Вы можете преобрести платную версию в JOJOS.Market)',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
