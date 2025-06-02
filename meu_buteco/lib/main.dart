import 'package:flutter/material.dart';
import 'package:meu_buteco/firebase_options.dart';
import 'package:meu_buteco/screens/cadastro_usuario_screen.dart';
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
          colorScheme: ColorScheme(
            brightness: Brightness.dark, // deixa tudo escuro
            primary: Colors.purple[900]!,
            onPrimary: Colors.white,
            secondary: Colors.purple[900]!,
            onSecondary: Colors.white,
            surface: Colors.purple[900]!,
            onSurface: Colors.white,
            error: Colors.red,
            onError: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.purple[900]!, // fundo das telas
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.purple, // cor do AppBar
            foregroundColor: Colors.white,    // cor dos textos/ícones do AppBar
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
            labelLarge: TextStyle(color: Colors.white),
            labelMedium: TextStyle(color: Colors.white),
            labelSmall: TextStyle(color: Colors.white),
          ),
        ),
        home: HomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const CadastroUsuarioScreen(), // <-- nova rota
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

