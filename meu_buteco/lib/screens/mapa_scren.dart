import 'package:flutter/material.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa dos Bares')),
      body: const Center(child: Text('Aqui vai o mapa dos bares!')),
    );
  }
}