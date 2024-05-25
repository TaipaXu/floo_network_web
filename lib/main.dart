import 'package:flutter/material.dart';
import '/pages/home.dart' as page;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floo Network',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: 'home',
      routes: {
        'home': (context) => const page.Home(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
