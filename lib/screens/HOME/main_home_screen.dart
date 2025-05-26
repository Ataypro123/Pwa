import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:hermes_pro/screens/HOME/slider_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings_manager.dart';


class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);
  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final GlobalKey<SliderDrawerState> dKey = GlobalKey<SliderDrawerState>();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SliderDrawer(
        key: dKey,
        slider: MySlider(),
        appBar: MyAppBar(drawerKey: dKey, isSimplified: isSimplified), // Передача `isSimplified`
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                  ),
                  onPressed: () {},
                  child: const Center(
                    child: Text(
                      'Как пользоваться?',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      if (!isSimplified) // Карточка склада показывается только в стандартном режиме
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(69, 104, 220, 1),
                              padding: const EdgeInsets.symmetric(vertical: 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/wmscreate');
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warehouse, size: 48, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(176, 106, 179, 1),
                            padding: const EdgeInsets.symmetric(vertical: 100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/cashier');
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store, size: 48, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 106, 179, 112),
                            padding: const EdgeInsets.symmetric(vertical: 100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/cashier1');
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.point_of_sale, size: 48, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/auth');
                  },
                  child: const Text(
                    'Смена роли',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<SliderDrawerState> drawerKey;
  final bool isSimplified; // Добавлено поле для передачи состояния

  const MyAppBar({Key? key, required this.drawerKey, required this.isSimplified}) : super(key: key);

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _MyAppBarState extends State<MyAppBar> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        controller.forward();
        widget.drawerKey.currentState!.openSlider();
      } else {
        controller.reverse();
        widget.drawerKey.currentState!.closeSlider();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 90,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: controller,
                  size: 40,
                ),
                onPressed: toggle,
              ),
            ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: TextButton.icon(
                  onPressed: () async {
                    const telegramUrl = 'https://t.me/AtayPro';
                    if (await canLaunch(telegramUrl)) {
                      await launch(telegramUrl);
                    } else {
                      throw 'Не удалось открыть Telegram';
                    }
                  },
                  icon: const Icon(Icons.face, color: Color.fromARGB(255, 0, 0, 0)),
                  label: const Text(
                    "Поддержка Jojos!",
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
