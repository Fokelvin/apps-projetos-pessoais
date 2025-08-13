import 'package:flutter/material.dart';
import 'package:meu_buteco/firebase_options.dart';
import 'package:meu_buteco/screens/register_user_screen.dart';
import 'package:meu_buteco/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meu_buteco/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:meu_buteco/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/user_profile_screen.dart';
import 'screens/search_screen.dart';
import 'widgets/themes.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Meu Buteco',
        theme: meuButecoTheme,
        home: HomeScreen(),
        routes: {
          '/home': (context) => HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const RegisterUserScreen(),
          '/userProfile': (context) => const UserProfileScreen(),
          '/search_bar': (context) => const SearchScreen(),
        },
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform, // ou apenas Firebase.initializeApp();
  );
  await dotenv.load(fileName: ".env");
  runApp(MainApp());
}
