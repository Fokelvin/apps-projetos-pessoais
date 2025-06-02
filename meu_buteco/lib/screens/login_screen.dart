import 'package:flutter/material.dart';
import 'package:meu_buteco/models/user_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, // texto preto
                  backgroundColor: Colors.white, // fundo branco (opcional)
                ),
              onPressed: () {
                Provider.of<UserProvider> (context, listen: false).signIn(
                  email: emailController.text, 
                  pass: passwordController.text, 
                  onSuccess: (){
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login realizado com sucesso!')),
                    );
                    Navigator.of(context).pop();
                  }, 
                  onFail: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Falha ao fazer login!')),
                    );
                  },
                );
              },
              child: const Text('Entrar'),
            ),
            SizedBox(height: 18.0),
            TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple[900], // texto preto
                ),
              onPressed: () {
                // Navegue para a tela de cadastro (crie a rota '/signup' se necessário)
                Navigator.of(context).pushNamed('/signup');
              },
              child: Text('Não tem cadastro? Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}