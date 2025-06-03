import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meu_buteco/models/bar_model.dart';
import 'package:geolocator/geolocator.dart';

class MapBarScreen extends StatefulWidget {
  const MapBarScreen({super.key});

  @override
  State<MapBarScreen> createState() => _MapBarScreenState();
}

class _MapBarScreenState extends State<MapBarScreen> {
  Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedBar;
  bool _showBarCard = false;
  final CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(-19.924648889180805, -43.93786504763702),
    zoom: 13,
  );

  GoogleMapController? _mapController;
  LatLng? _closestBar;
  String? _closestBarName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarBares();
  }

  // ALTERAÇÃO: Adicionado método dispose para limpar recursos
  @override
  void dispose() {
    // Limpa o controller do mapa se existir para evitar vazamentos de memória
    _mapController?.dispose();
    super.dispose();
  }


  Future<void> _carregarBares() async {
    try {
      final lista = await BarModel.buscarBares();
      
      if (!mounted) return;
      
      // Definir o bar mais próximo
      if (lista.isNotEmpty) {
        final primeiroBar = lista.first;
        final lat = BarModel.parseCoordinate(primeiroBar['lat'], 'lat');
        final lng = BarModel.parseCoordinate(primeiroBar['long'], 'long');
        _closestBar = LatLng(lat, lng);
        _closestBarName = primeiroBar['nome'];

        _selectedBar = primeiroBar;
        _showBarCard  = true;
      }
      
      setState(() {
        _markers = lista.map((bar) {
          final lat = BarModel.parseCoordinate(bar['lat'], 'lat');
          final lng = BarModel.parseCoordinate(bar['long'], 'long');
          
          return Marker(
            markerId: MarkerId(bar['nome']),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: bar['nome'],
              snippet: bar['endereco'] ?? 'Endereço não informado',
              onTap: () {
                if (!mounted) return;
                setState(() {
                  _selectedBar = bar;
                  _showBarCard = true;
                });
              },
            ),
            onTap: () {
              if (!mounted) return;
              setState(() {
                _selectedBar = bar;
                _showBarCard = true;
              });
            },
          );
        }).toSet();
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar bares: $e');
      if (!mounted) return;
      setState(() {
        _markers = {};
        _isLoading = false;
      });
    }
  }

  Future<void> _recarregarBares() async {
    await _carregarBares();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa dos Bares'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregarBares,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _cameraPosition,
            markers: _markers,
            onMapCreated: (controller) {
              try {
                _mapController = controller;
              } catch (e) {
                print('Erro ao criar mapa: $e');
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
          ),
          
          // Indicador de carregamento
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Card informativo sobre o bar mais próximo
          if (!_isLoading && _closestBarName != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bar mais próximo: $_closestBarName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}