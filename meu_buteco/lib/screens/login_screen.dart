import 'package:flutter/material.dart';

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
              onPressed: () {
                // Aqui você pode chamar seu provider para autenticar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login não implementado')),
                );
              },
              child: const Text('Entrar'),
            ),
            SizedBox(height: 18.0),
            TextButton(
              onPressed: () {
                // Navegue para a tela de cadastro (crie a rota '/signup' se necessário)
                Navigator.of(context).pushNamed('/signup');
              },
              child: const Text('Não tem cadastro? Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}