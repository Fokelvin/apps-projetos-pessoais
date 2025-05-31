import 'package:flutter/material.dart';
import 'package:meu_buteco/firebase_options.dart';
import 'package:meu_buteco/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:scoped_model/scoped_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ou apenas Firebase.initializeApp();
  );
  runApp(MainApp());
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

