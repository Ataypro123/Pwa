import 'package:flutter/material.dart';
import 'package:hermes_pro/Utils/colors.dart';
import 'package:hermes_pro/screens/HOME/Slider_pages/information_page.dart';
import 'package:hermes_pro/screens/HOME/Slider_pages/jojos_market_page.dart';
import 'package:hermes_pro/screens/HOME/Slider_pages/profile_page.dart';
import 'package:hermes_pro/screens/HOME/Slider_pages/settings_page.dart';

class MySlider extends StatelessWidget {
  
  MySlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: MyColors.primaryGradientColor,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 35,
          ),
          const SizedBox(height: 20),
          Text("Dzheenbekov Atay", style: textTheme.headlineMedium),
          Text("Владелец", style: textTheme.headlineSmall),
          const SizedBox(height: 45),
          Column(
            children: [
              // Home Button
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JojosMarketPage()),
                  );
                },
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text("JOJOS Market", style: TextStyle(color: Colors.white,fontSize: 30)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
              // Profile Button
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(
                    )),
                  );
                },
                icon: const Icon(Icons.person, color: Colors.white),
                label: const Text("Профиль", style: TextStyle(color: Colors.white,fontSize: 30)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
              // Settings Button
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
                icon: const Icon(Icons.settings, color: Colors.white),
                label: const Text("Настройки", style: TextStyle(color: Colors.white,fontSize: 30)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
              // Details Button
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InformationPage()),
                  );
                },
                icon: const Icon(Icons.info, color: Colors.white),
                label: const Text("Информация", style: TextStyle(color: Colors.white,fontSize: 30)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
