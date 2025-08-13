// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meu_buteco/models/bar_model.dart';
import 'dart:developer' as developer;
import 'package:permission_handler/permission_handler.dart';

class MapBarScreen extends StatefulWidget {
  final double? lat;
  final double? long;
  final String? barName;
  final String? selectedBarId; // ou use o nome, se preferir

  const MapBarScreen({
    super.key,
    this.lat,
    this.long,
    this.barName,
    this.selectedBarId,
  });

  @override
  State<MapBarScreen> createState() => _MapBarScreenState();
}

class _MapBarScreenState extends State<MapBarScreen> {
  Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedBar;
  bool _showBarCard = false;
  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(-19.924648889180805, -43.93786504763702),
    zoom: 18,
  );

  GoogleMapController? _mapController;
  LatLng? _closestBar;
  String? _closestBarName;
  bool _isLoading = true;
  String? _selectedBarId;
  String? _errorMessage;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    developer.log('MapBarScreen: initState iniciado');

    if (widget.lat != null && widget.long != null) {
      developer.log(
        'MapBarScreen: Coordenadas recebidas - lat: ${widget.lat}, long: ${widget.long}',
      );
      _cameraPosition = CameraPosition(
        target: LatLng(widget.lat!, widget.long!),
        zoom: 18,
      );
      _closestBar = LatLng(widget.lat!, widget.long!);
      _closestBarName = widget.barName;
    }
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _requestLocationPermission();
    _carregarBares();
  }

  Future<void> _requestLocationPermission() async {
    try {
      developer.log('MapBarScreen: Verificando permissões de localização');

      // Verifica o status atual da permissão
      PermissionStatus status = await Permission.location.status;
      developer.log('MapBarScreen: Status da permissão: $status');

      if (status.isGranted) {
        developer.log('MapBarScreen: Permissão já concedida');
        setState(() {
          _locationPermissionGranted = true;
        });
        return;
      }

      if (status.isDenied) {
        developer.log('MapBarScreen: Solicitando permissão de localização');
        status = await Permission.location.request();
        developer.log('MapBarScreen: Resultado da solicitação: $status');
      }

      if (status.isPermanentlyDenied) {
        developer.log('MapBarScreen: Permissão negada permanentemente');
        setState(() {
          _errorMessage =
              'Permissão de localização negada. Vá em Configurações > Apps > Meu Buteco > Permissões e habilite a localização.';
        });
        return;
      }

      if (status.isGranted) {
        developer.log('MapBarScreen: Permissão concedida com sucesso');
        setState(() {
          _locationPermissionGranted = true;
        });
      } else {
        developer.log('MapBarScreen: Permissão negada');
        setState(() {
          _errorMessage =
              'Permissão de localização necessária para mostrar sua localização no mapa.';
        });
      }
    } catch (e) {
      developer.log('MapBarScreen: Erro ao solicitar permissão: $e');
      setState(() {
        _errorMessage = 'Erro ao solicitar permissão de localização: $e';
      });
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
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
      developer.log('MapBarScreen: Iniciando carregamento dos bares');
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final lista = await BarModel.buscarBares();
      developer.log(
        'MapBarScreen: Bares carregados - ${lista.length} bares encontrados',
      );

      if (!mounted) {
        developer.log('MapBarScreen: Widget não está mais montado, abortando');
        return;
      }

      // Se um bar específico foi passado, encontrá-lo na lista pelas coordenadas
      Map<String, dynamic>? barSelecionado;
      if (widget.lat != null && widget.long != null) {
        barSelecionado = lista.firstWhere((bar) {
          final barLat = BarModel.parseCoordinate(bar['lat'], 'lat');
          final barLng = BarModel.parseCoordinate(bar['long'], 'long');
          // Comparar coordenadas com uma pequena tolerância para diferenças de precisão
          return (barLat - widget.lat!).abs() < 0.0001 &&
              (barLng - widget.long!).abs() < 0.0001;
        }, orElse: () => lista.first);
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
          _selectedBarId = barSelecionado['id'];
          setState(() {
            _selectedBar = barSelecionado;
            _showBarCard = true;
          });
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
        _markers =
            lista.map((bar) {
              final lat = BarModel.parseCoordinate(bar['lat'], 'lat');
              final lng = BarModel.parseCoordinate(bar['long'], 'long');

              return Marker(
                markerId: MarkerId(bar['nome']),
                position: LatLng(lat, lng),
                icon:
                    _selectedBarId == bar['id']
                        ? BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ) // cor diferente
                        : BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: bar['nome'],
                  snippet: bar['endereco'] ?? 'Endereço não informado',
                  onTap: () {
                    if (!mounted) return;
                    setState(() {
                      _selectedBar = bar;
                      _showBarCard = true;
                      _selectedBarId = bar['id'];
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
        developer.log(
          'MapBarScreen: Mapa atualizado com ${_markers.length} marcadores',
        );
      });
    } catch (e) {
      developer.log('MapBarScreen: Erro ao carregar bares: $e');
      if (!mounted) return;
      setState(() {
        _markers = {};
        _isLoading = false;
        _errorMessage = 'Erro ao carregar bares: $e';
      });
    }
  }

  Future<void> _recarregarBares() async {
    developer.log('MapBarScreen: Recarregando bares');
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
          // Widget de debug temporário
          if (_errorMessage != null || _isLoading)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Card(
                color:
                    _errorMessage != null ? Colors.red[100] : Colors.blue[100],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage != null ? 'ERRO:' : 'DEBUG:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (_errorMessage != null)
                        Text(_errorMessage!)
                      else ...[
                        Text('Carregando: $_isLoading'),
                        Text('Marcadores: ${_markers.length}'),
                        Text(
                          'Camera: ${_cameraPosition.target.latitude}, ${_cameraPosition.target.longitude}',
                        ),
                        Text('Permissão: $_locationPermissionGranted'),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          GoogleMap(
            initialCameraPosition: _cameraPosition,
            markers: _markers,
            onMapCreated: (controller) {
              try {
                developer.log('MapBarScreen: Mapa criado com sucesso');
                _mapController = controller;
              } catch (e) {
                developer.log('MapBarScreen: Erro ao criar mapa: $e');
                setState(() {
                  _errorMessage = 'Erro ao criar mapa: $e';
                });
              }
            },
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: _locationPermissionGranted,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
          ),

          // Indicador de carregamento
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Mensagem de erro
          if (_errorMessage != null)
            Container(
              color: Colors.red.withValues(alpha: 0.8),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: Colors.white, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _recarregarBares,
                            child: const Text('Tentar Novamente'),
                          ),
                          if (_errorMessage!.contains('Permissão'))
                            ElevatedButton(
                              onPressed: _openAppSettings,
                              child: const Text('Configurações'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Card informativo sobre o bar
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
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(26),
                            backgroundImage:
                                (_selectedBar!["linkImagem"] != null &&
                                        _selectedBar!["linkImagem"]
                                            .toString()
                                            .isNotEmpty)
                                    ? NetworkImage(_selectedBar!["linkImagem"])
                                    : const AssetImage('assets/icon/icon.png')
                                        as ImageProvider,
                            child:
                                (_selectedBar!["linkImagem"] == null ||
                                        _selectedBar!["linkImagem"]
                                            .toString()
                                            .isEmpty)
                                    ? null
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
                                  _selectedBar!['endereco'] ??
                                      'Endereço não informado',
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
