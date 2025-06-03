import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class BarModel {
  final String nome;
  final String latitude;
  final String longitude;
  final String linkImagem;
  
  BarModel(this.nome, this.latitude, this.longitude, this.linkImagem);

  Map<String, dynamic> toMap(){
    return {
      "nome" : nome, 
      "lat" : latitude,
      "long": longitude,
      "linkImagem": linkImagem
    };
  }

  Future<void> salvarNoFirebase() async{
    await FirebaseFirestore.instance.collection("bares").add(toMap());
  }

  static Future<List<Map<String, dynamic>>> buscarBares() async {
    final snapshot = await FirebaseFirestore.instance.collection('bares').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Método para parse de coordenadas
  static double parseCoordinate(dynamic value, String fieldName) {
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
    
    if (value is bool) {
      print('Aviso: Campo $fieldName é boolean ($value). Convertendo para 0.0');
      return 0.0;
    }
    
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

  // Método para buscar endereço
  static Future<String> getEndereco(double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) {
      return "Coordenadas não informadas";
    }
    
    print('Buscando endereço para: lat=$lat, lng=$lng');
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      print('Placemarks retornados: $placemarks');
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
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