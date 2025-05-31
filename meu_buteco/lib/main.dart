import 'package:flutter/material.dart';
import 'package:meu_buteco/firebase_options.dart';
import 'package:meu_buteco/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meu_buteco/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:meu_buteco/models/user_model.dart';

// ...existing imports...

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Meu Buteco',
        theme: ThemeData(
          primaryColor: Colors.blueGrey[900],
        ),
        home: HomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ou apenas Firebase.initializeApp();
  );
  runApp(MainApp());
}

