import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'screens/phone_list_screen.dart';
import 'services/mock_phone_service.dart';
import 'services/phone_service.dart';

void main() => runApp(PhoneApp());

class PhoneApp extends StatelessWidget {
  PhoneApp({super.key})
      : source = ApiConfig.useMock ? MockPhoneService() : PhoneService();

  final PhoneSource source;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danh mục điện thoại',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: PhoneListScreen(source: source),
    );
  }
}
