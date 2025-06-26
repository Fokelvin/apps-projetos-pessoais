import 'package:flutter/material.dart';
import 'package:meu_buteco/firebase_options.dart';
import 'package:meu_buteco/screens/cadastro_usuario_screen.dart';
import 'package:meu_buteco/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meu_buteco/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:meu_buteco/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/user_profile_screen.dart';



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
            brightness: Brightness.light,
            primary: Colors.white,      // fundo e botões principais
            onPrimary: Colors.black,    // textos/ícones sobre primary
            secondary: Colors.white,    // pode ser igual ao primary
            onSecondary: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
            error: Colors.red,
            onError: Colors.white,
          ),
            inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.black), // label quando não focado
            floatingLabelStyle: TextStyle(color: Colors.purple[900]),
            filled: true, // ativa o preenchimento
            fillColor: Colors.grey[100], // cor de fundo levemente cinza
            border: OutlineInputBorder(), // borda padrão
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey), // borda quando não focado
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.purple[900]!), // borda quando focado
            ), // label quando focado
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
            bodySmall: TextStyle(color: Colors.black),
          ),
        ),
        home: HomeScreen(),
        routes: {
          '/home' : (context) => HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const CadastroUsuarioScreen(),
          '/userProfile': (context) => const UserProfileScreen(),
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
  await dotenv.load(fileName: ".env");
  runApp(MainApp());
}

