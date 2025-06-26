// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meu_buteco/models/bar_model.dart';

class MapBarScreen extends StatefulWidget {

  final double? lat;
  final double? long;
  final String? barName;
  
  const MapBarScreen({super.key, this.lat, this.long, this.barName});

  @override
  State<MapBarScreen> createState() => _MapBarScreenState();
}

class _MapBarScreenState extends State<MapBarScreen> {
  Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedBar;
  bool _showBarCard = false;
  CameraPosition _cameraPosition = const CameraPosition(
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
    if(widget.lat != null && widget.long != null){
      _cameraPosition = CameraPosition(
        target: LatLng(widget.lat!, widget.long!),
        zoom: 15
      );
      _closestBar = LatLng(widget.lat!, widget.long!);
      _closestBarName = widget.barName;
    }
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
      
      // Se um bar específico foi passado, encontrá-lo na lista pelas coordenadas
      Map<String, dynamic>? barSelecionado;
      if (widget.lat != null && widget.long != null) {
        barSelecionado = lista.firstWhere(
          (bar) {
            final barLat = BarModel.parseCoordinate(bar['lat'], 'lat');
            final barLng = BarModel.parseCoordinate(bar['long'], 'long');
            // Comparar coordenadas com uma pequena tolerância para diferenças de precisão
            return (barLat - widget.lat!).abs() < 0.0001 && 
                   (barLng - widget.long!).abs() < 0.0001;
          },
          orElse: () => lista.first,
        );
      }
      
      // Definir o bar para mostrar no card superior
      if (lista.isNotEmpty) {
        if (barSelecionado != null) {
          // Se um bar específico foi passado, mostrar ele
          final lat = BarModel.parseCoordinate(barSelecionado['lat'], 'lat');
          final lng = BarModel.parseCoordinate(barSelecionado['long'], 'long');
          _closestBar = LatLng(lat, lng);
          _closestBarName = barSelecionado['nome'];
          
          // Selecionar automaticamente
          _selectedBar = barSelecionado;
          _showBarCard = true;
        } else {
          // Se não foi passado bar específico, mostrar o primeiro da lista
          final primeiroBar = lista.first;
          final lat = BarModel.parseCoordinate(primeiroBar['lat'], 'lat');
          final lng = BarModel.parseCoordinate(primeiroBar['long'], 'long');
          _closestBar = LatLng(lat, lng);
          _closestBarName = primeiroBar['nome'];
        }
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
                //print('Erro ao criar mapa: $e');
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
          
          // Card informativo sobre o bar
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
                          widget.lat != null && widget.long != null
                              ? 'Bar selecionado: $_closestBarName'
                              : 'Bar destacado: $_closestBarName',
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
          if (_showBarCard && _selectedBar != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                            backgroundImage: _selectedBar!["linkImagem"] != null
                                ? NetworkImage(_selectedBar!["linkImagem"])
                                : null,
                            child: _selectedBar!["linkImagem"] == null
                                ? const Icon(Icons.sports_bar)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedBar!['nome'] ?? 'Nome não informado',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _selectedBar!['endereco'] ?? 'Endereço não informado',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _showBarCard = false;
                                _selectedBar = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (_selectedBar!['wifi'] == true)
                            const Chip(
                              label: Text('Wi-Fi'),
                              backgroundColor: Colors.green,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          const SizedBox(width: 8),
                          if (_selectedBar!['transmissao']?['tv'] == true)
                            const Chip(
                              label: Text('TV'),
                              backgroundColor: Colors.blue,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          const SizedBox(width: 8),
                          if (_selectedBar!['transmissao']?['telao'] == true)
                            const Chip(
                              label: Text('Telão'),
                              backgroundColor: Colors.orange,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                        ],
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