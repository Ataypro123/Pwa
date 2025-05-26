import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hermes_pro/Data/warehouse.dart';
import 'package:hermes_pro/screens/AUTH/auth_page.dart';
import 'package:hermes_pro/screens/HOME/main_home_screen.dart';
import 'package:hermes_pro/screens/HOME/Warehouse/WMS/WMS.dart'; // импорт страницы WMS
import 'package:hive_flutter/hive_flutter.dart';
import 'Data/cash_book_line.dart';
import 'Data/delivery.dart';
import 'Data/payment_method.dart';
import 'Data/receipt_item.dart';
import 'Data/shared_item.dart';
import 'Data/shift_status.dart';
import 'Data/user_settings.dart';
import 'firebase_options.dart';
import 'screens/AUTH/reg_page.dart';
import 'screens/HOME/Kassa/CashdeskOperations.dart';
import 'screens/HOME/Shop_manager/MainPage.dart';
import 'screens/HOME/Warehouse/wms_create.dart'; 

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
    // Регистрация адаптера 
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(DeliveryAdapter());
  Hive.registerAdapter(DeliveryItemAdapter()); 
  Hive.registerAdapter(WarehouseAdapter());
  Hive.registerAdapter(SharedItemAdapter()); // Регистрация адаптера
  Hive.registerAdapter(ReceiptItemAdapter()); // Регистрация адаптера
  Hive.registerAdapter(DebtorItemAdapter());
  Hive.registerAdapter(ReturnItemAdapter());
  Hive.registerAdapter(ShiftStatusAdapter());
  Hive.registerAdapter(PaymentMethodAdapter());
  Hive.registerAdapter(CashBookLineAdapter());
  Hive.registerAdapter(CashDocumentAdapter());

  // Открытие коробки
  await Hive.openBox<Delivery>('storageUnitBox');
  await Hive.openBox<Warehouse>('warehouseBox');
  await Hive.openBox<SharedItem>('sharedItemsBox'); // Открытие коробки для SharedItem
  await Hive.openBox<ReceiptItem>('receiptBox');
  await Hive.openBox<DebtorItem>('debtorReceiptBox');
  await Hive.openBox<UserSettings>('settingsBox'); // Открываем бокс для настроек
  await Hive.openBox<ReturnItem>('returnBox');
  await Hive.openBox<ShiftStatus>('shiftStatusBox');
  await Hive.openBox<CashBookLine>('cashBook');

  runApp( MyApp());  
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "JOJOS.PRO.",
      theme: ThemeData(
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
            routes: {
        '/auth': (context) => AuthPage(),
        '/register': (context) => RegistrationPage(),
        '/': (context) => MainHomeScreen(),
        '/wmscreate': (context) => WarehouseSelectionPage(),
        '/cashier': (context) => MainPage(),
        '/cashier1': (context) => CashdeskOperations(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/wms') {
          final warehouse = settings.arguments as Warehouse;
          return MaterialPageRoute(
            builder: (context) => WMSPage(warehouse: warehouse),
          );
        }
        return null;
      },
    );
  }
  
}
