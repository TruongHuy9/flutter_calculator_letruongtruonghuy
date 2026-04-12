import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calculator_simple.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calculator',
      theme: ThemeData(
        fontFamily: 'Inter', 
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}