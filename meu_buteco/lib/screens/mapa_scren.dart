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
  final Set<Marker> _markers = {};
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
    // ALTERAÇÃO: Verificação de 'mounted' antes de setState para evitar erro
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bares = await BarModel.buscarBares();
      
      // ALTERAÇÃO: Verificação de 'mounted' após operação assíncrona
      if (!mounted) return;

      Position? userPosition;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Permissão de localização negada');
          }
        }

        if (permission == LocationPermission.deniedForever) {
          throw Exception('Permissão de localização negada permanentemente');
        }

        userPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
          ),
        );
        
        // ALTERAÇÃO: Verificação de 'mounted' após obter localização
        if (!mounted) return;
        
      } catch (e) {
        print('Erro ao obter localização: $e');
        userPosition = null;
      }

      double minDist = double.infinity;
      LatLng? closestBar;
      String? closestBarName;
      String? closestBarId;

      // Primeiro loop - encontra o bar mais próximo
      if (userPosition != null) {
        for (var bar in bares) {
          final lat = double.tryParse(bar['lat'].toString()) ?? 0.0;
          final lng = double.tryParse(bar['long'].toString()) ?? 0.0;
          
          final dist = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            lat,
            lng,
          );
          
          if (dist < minDist) {
            minDist = dist;
            closestBar = LatLng(lat, lng);
            closestBarName = bar['nome'];
            closestBarId = bar['nome'];
          }
        }
      }

      // ALTERAÇÃO: Verificação de 'mounted' antes de setState para evitar erro
      if (!mounted) return;

      setState(() {
        _markers.clear();
        
        // Segundo loop - cria os marcadores com o conhecimento de qual é o mais próximo
        for (var bar in bares) {
          final lat = double.tryParse(bar['lat'].toString()) ?? 0.0;
          final lng = double.tryParse(bar['long'].toString()) ?? 0.0;
          final markerPos = LatLng(lat, lng);
          final isClosest = bar['nome'] == closestBarId;

          _markers.add(
            Marker(
              markerId: MarkerId(bar['nome']),
              position: markerPos,
              infoWindow: InfoWindow(
                title: bar['nome'],
                snippet: isClosest && userPosition != null 
                    ? 'Bar mais próximo - ${(minDist / 1000).toStringAsFixed(2)} km' 
                    : null,
              ),
              icon: isClosest && userPosition != null 
                  ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
                  : BitmapDescriptor.defaultMarker,
            ),
          );
        }

        // Armazena informações do bar mais próximo
        if (closestBar != null) {
          _closestBar = closestBar;
          _closestBarName = closestBarName;
        }
        
        _isLoading = false;
      });

      // ALTERAÇÃO: Animação da câmera com verificações adicionais de 'mounted' e try-catch
      if (closestBar != null && mounted) {
        // Aguarda um pequeno delay para garantir que o mapa foi renderizado
        Future.delayed(const Duration(milliseconds: 500), () async {
          // ALTERAÇÃO: Verificação de 'mounted' após delay
          if (_mapController != null && mounted) {
            try {
              await _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: closestBar!, 
                    zoom: 17,
                  ),
                ),
              );
            } catch (e) {
              // ALTERAÇÃO: Try-catch para capturar erros de animação
              print('Erro ao animar câmera: $e');
            }
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar bares: $e');
      // ALTERAÇÃO: Verificação de 'mounted' antes de setState no catch
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            onMapCreated: (controller) async {
              _mapController = controller;
              
              // ALTERAÇÃO: Verificação de 'mounted' e try-catch na criação do mapa
              if (_closestBar != null && mounted) {
                try {
                  await Future.delayed(const Duration(milliseconds: 300));
                  // ALTERAÇÃO: Verificação adicional após delay
                  if (mounted) {
                    await _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _closestBar!, 
                          zoom: 17,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  // ALTERAÇÃO: Try-catch para capturar erros na animação inicial
                  print('Erro ao animar câmera inicial: $e');
                }
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