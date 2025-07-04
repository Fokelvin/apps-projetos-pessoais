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
      body: SingleChildScrollView(
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
                  onFail: (erro) async {
                    await showDialog(
                      context: context, 
                      builder: (build) => AlertDialog(
                        title: Text('Falha ao fazer login'),
                        content: Text(erro),
                        actions: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  //Reenvia o email de verificação
                                  final user = Provider.of<UserProvider>(context, listen: false).firebaseUser;
                                  if(user != null && !user.emailVerified){
                                    await user.sendEmailVerification();
                                        // Adicione esta verificação
                                    if (!context.mounted) return;

                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Email de confirmado reenviado'),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  } else{
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Não foi possível reenviar. Tente novamente após tentar login.',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                }, 
                                child: Text('Não recebeu? Reenviar email de confirmação',
                                  style: TextStyle(
                                      color: Colors.black,
                                  ),
                                )
                              ),
                            ],
                          )

                        ],
                      )
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
            TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple[900], // texto preto
                ),
              onPressed: () {
                final email = emailController.text.trim();
                if(email.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Informe seu e-mail para recuperar a senha"))
                  );
                  return;
                }
                Provider.of<UserProvider>(context, listen: false).recoverPass(
                  email: email, 
                  onSuccess: (){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("E-mail de recuperação enviado"))
                    );
                  },
                  onFail: (erro){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erro para enviar e-mail de recuperação enviado"))
                    );
                  }
                );
              },
              child: Text('Esqueci minha senha'),
            ),
          ],
        ),
      ),
    );
  }
}