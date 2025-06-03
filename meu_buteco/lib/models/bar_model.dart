import 'package:cloud_firestore/cloud_firestore.dart';


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

  void _buscarBares() async {
    final snapshot = await FirebaseFirestore.instance.collection('bares').get();
    
    final bares = snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<List<Map<String, dynamic>>> buscarBares() async {
    final snapshot = await FirebaseFirestore.instance.collection('bares').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

}