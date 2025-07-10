import 'package:flutter/material.dart';

final ThemeData meuButecoTheme = ThemeData(
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
);