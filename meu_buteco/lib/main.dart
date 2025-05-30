import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Buteco', // É bom adicionar um título ao MaterialApp
      theme: ThemeData(
        primaryColor: Colors.blueGrey[900],
      ),
      home: HomeScreen(),
    );
  }
}
