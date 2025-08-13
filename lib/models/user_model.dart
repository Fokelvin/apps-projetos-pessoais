import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class UserProvider extends ChangeNotifier {
  static final Logger _logger = Logger();
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? firebaseUser;

  Map<String, dynamic> userData = {};

  // Método estático para acessar o provider facilmente
  static UserProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<UserProvider>(context, listen: listen);

  UserProvider() {
    _loadCurrentUser();
  }
  String get userId => firebaseUser?.uid ?? "";

  void signUp({
    required Map<String, dynamic> userData,
    required String pass,
    required VoidCallback onSuccess,
    required Function(String) onFail,
  }) {
    isLoading = true;
    notifyListeners();

    _auth
        .createUserWithEmailAndPassword(
          email: userData["email"],
          password: pass,
        )
        .then((userCredential) async {
          firebaseUser = userCredential.user;

          // Envia o e-mail de verificação
          await firebaseUser?.sendEmailVerification();

          // Aqui você pode salvar os dados se ainda não existirem
          await _saveUserData(userData);

          onSuccess();
          isLoading = false;
          notifyListeners();
        })
        .catchError((error) {
          isLoading = false;
          notifyListeners();

          String errorMessage;

          if (error is FirebaseAuthException) {
            switch (error.code) {
              case 'email-already-in-use':
              case 'ERROR_EMAIL_ALREADY_IN_USE':
                errorMessage = 'Este e-mail já está cadastrado.';
                break;
              case 'invalid-email':
                errorMessage = 'O e-mail fornecido é inválido.';
                break;
              case 'weak-password':
                errorMessage = 'A senha fornecida é muito fraca.';
                break;
              default:
                errorMessage =
                    error.message ?? 'Falha ao criar usuário (Firebase).';
            }
          } else {
            errorMessage = 'Ocorreu um erro desconhecido ao criar o usuário.';
          }
          onFail(errorMessage);
          isLoading = false;
          notifyListeners();
        });
  }

  void signIn({
    required String email,
    required String pass,
    required VoidCallback onSuccess,
    required Function(String) onFail,
  }) async {
    isLoading = true;
    notifyListeners();

    _auth
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((userCredential) async {
          firebaseUser = userCredential.user;

          // RECARREGUE O USUÁRIO AQUI!
          await firebaseUser?.reload();
          firebaseUser = _auth.currentUser;

          if (firebaseUser != null && !firebaseUser!.emailVerified) {
            _logger.i(firebaseUser);
            await _auth.signOut();
            firebaseUser = null;
            isLoading = false;
            notifyListeners();
            onFail('Por favor, verifique seu e-mail antes de acessar.');
            return;
          }

          await _loadCurrentUser();

          onSuccess();
          isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          onFail(e);
          isLoading = false;
          notifyListeners();
        });
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser?.uid)
        .set(userData);
  }

  Future<void> recoverPass({
    required String email,
    required VoidCallback onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      onSuccess();
    } catch (e) {
      onFail(e.toString());
    }
  }

  // Método isLogged estava vazio, removido para evitar confusão
  // Se precisar, pode implementar uma lógica específica aqui

  bool isLoggedIn() {
    return firebaseUser != null;
  }

  void signOut() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));
    await _auth.signOut();
    userData = {};

    isLoading = false;
    firebaseUser = null;
    notifyListeners();
  }

  // Future<void> _saveUserData(Map<String, dynamic> userData) async {
  //   this.userData = userData;
  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(firebaseUser?.uid)
  //       .set(userData);
  // }

  Future<void> _loadCurrentUser() async {
    firebaseUser ??= _auth.currentUser;

    if (firebaseUser != null) {
      if (userData["name"] == null) {
        DocumentSnapshot docUser =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(firebaseUser!.uid)
                .get();
        userData = docUser.data() as Map<String, dynamic>? ?? {};
      }
    }
    notifyListeners();
  }

  // Método para verificar se o usuário é master (assumindo que existe um campo no Firestore)
  bool get isMaster {
    return userData["isMaster"] ?? false;
  }

  Future<void> atualizarPerfil({
    required String nome,
    required String endereco,
    required String telefone,
  }) async {
    // Aqui você pode fazer a chamada para o backend, Firebase, etc.
    // Exemplo simples:
    userData['name'] = nome;
    userData['endereco'] = endereco;
    userData['telefone'] = telefone;
    notifyListeners();
  }

  // Getters úteis para acessar dados do usuário
  String get userName => userData["name"] ?? "";
  String get userEmail => userData["email"] ?? "";
}
