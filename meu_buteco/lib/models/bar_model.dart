import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';// ...existing code...

class BarModel {

  final String nome;
  final String endereco;
  final String linkImagem;
  
  BarModel(this.endereco, this.nome, this.linkImagem);

  Map<String, dynamic> toMap(){
    return {
      "nome":nome, 
      "endereco": endereco,
      "linkImagem": linkImagem
    };
  }

  Future<void> salvarNoFirebase() async{
    await FirebaseFirestore.instance.collection("bares").add(toMap());
  }
}