import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/mapa_scren.dart';
import '../drawer/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import '../models/bar_model.dart';
import '../widgets/bar_card.dart'; // ajuste o caminho se necessário

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  PageController _pageController = PageController();

  List<Map<String, dynamic>> bares = [];
  List<bool> _expanded = []; // Lista para controlar quais cards estão expandidos

  @override
  void initState() {
    super.initState();
    _buscarBares();
    // Limpa qualquer dado antigo do PageStorage que possa estar causando conflito
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearPageStorage();
    });
  }

  // Método para limpar o PageStorage e evitar conflitos
  void _clearPageStorage() {
    try {
      final pageStorage = PageStorage.maybeOf(context);
      if (pageStorage != null) {
        // Limpa dados antigos que podem estar causando conflito de tipos
        pageStorage.writeState(context, null);
      }
    } catch (e) {
      print('Erro ao limpar PageStorage: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer
      drawer: const AppDrawer(),
      // AppBar
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sports_bar_sharp,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),                
                Icon(Icons.favorite,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Meu Buteco",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              ],
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      // PageView
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Página de lista de bares com título "Destaques"
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Destaques',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: bares.isEmpty || bares.length != _expanded.length
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: bares.length,
                        itemBuilder: (context, index) {
                          final bar = bares[index];
                          final lat = _parseCoordinate(bar['lat'], 'lat');
                          final lng = _parseCoordinate(bar['long'], 'long');

                           return BarCard(
                              bar: bar,
                              lat: lat,
                              lng: lng,
                              expanded: _expanded[index],
                              onExpansionChanged: (expanded) {
                                if (mounted && index < _expanded.length) {
                                  setState(() {
                                    _expanded[index] = expanded;
                                  });
                                }
                              },
                              getEndereco: getEndereco,
                            );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
      
      // Navigation icons
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[900],
        backgroundColor: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          if (index == 1) {
            // Abre o mapa como nova tela
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MapBarScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }

  // Função mais específica para coordenadas (corrigida)
  double _parseCoordinate(dynamic value, String fieldName) {
    if (value == null) {
      print('Aviso: Campo $fieldName é null');
      return 0.0;
    }
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    
    if (value is String) {
      final cleanValue = value.trim();
      if (cleanValue.isEmpty) {
        print('Aviso: Campo $fieldName está vazio');
        return 0.0;
      }
      final parsed = double.tryParse(cleanValue);
      if (parsed == null) {
        print('Erro: Não foi possível converter $fieldName: "$cleanValue" para double');
      }
      return parsed ?? 0.0;
    }
    
    // Se é bool, trata especialmente
    if (value is bool) {
      print('Aviso: Campo $fieldName é boolean ($value). Convertendo para 0.0');
      return 0.0; // ou você pode usar: value ? 1.0 : 0.0
    }
    
    // Para outros tipos, tenta converter toString() e depois parse
    try {
      final stringValue = value.toString();
      final parsed = double.tryParse(stringValue);
      if (parsed == null) {
        print('Erro: Campo $fieldName tem tipo inesperado: ${value.runtimeType}, valor: $value');
      }
      return parsed ?? 0.0;
    } catch (e) {
      print('Erro ao converter $fieldName para double: $value (tipo: ${value.runtimeType})');
      return 0.0;
    }
  }
  
  void _buscarBares() async {
    try {
      final lista = await BarModel.buscarBares();
      if (mounted) {
        // Limpa o PageStorage antes de atualizar os dados
        _clearPageStorage();
        
        setState(() {
          bares = lista;
          _expanded = List.generate(lista.length, (_) => false);
        });
      }
    } catch (e) {
      print('Erro ao buscar bares: $e');
      if (mounted) {
        setState(() {
          bares = [];
          _expanded = [];
        });
      }
    }
  }

  Future<String> getEndereco(double lat, double lng) async {
    // Verifica se as coordenadas são válidas
    if (lat == 0.0 && lng == 0.0) {
      return "Coordenadas não informadas";
    }
    
    print('Buscando endereço para: lat=$lat, lng=$lng');
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      print('Placemarks retornados: $placemarks');
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Monta o endereço de forma mais robusta
        List<String> enderecoParts = [];
        
        if (place.street != null && place.street!.isNotEmpty) {
          enderecoParts.add(place.street!);
        }
        if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
          enderecoParts.add(place.subThoroughfare!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          enderecoParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          enderecoParts.add(place.locality!);
        }
        
        return enderecoParts.isNotEmpty 
            ? enderecoParts.join(', ') 
            : "Endereço não encontrado";
      }
      return "Endereço não encontrado";
    } catch (e) {
      print('Erro ao buscar endereço: $e');
      return "Erro ao buscar endereço";
    }
  }
}