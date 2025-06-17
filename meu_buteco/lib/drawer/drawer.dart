import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/cadastro_bar_screen.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildDrawerBack() => Container(
      color: Theme.of(context).colorScheme.primary,
    );

    return Drawer(
      child: IconTheme(
        data: IconThemeData(
          color: Colors.black, // todos os ícones filhos serão brancos
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            listTileTheme: ListTileThemeData(
              selectedColor: Colors.black, // cor do texto/ícone selecionado
              iconColor: Colors.black,     // cor dos ícones
              textColor: Colors.black,    
              selectedTileColor: Colors.transparent, // cor do texto
            ),
          ),
          child: Stack(
            children: <Widget>[
              buildDrawerBack(),
              ListView(
                padding: const EdgeInsets.only(left: 32.0, top: 16.0),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "Opções",
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            final isLogged = userProvider.isLoggedIn();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Olá, ${userProvider.isLoggedIn() ? userProvider.userName : "Visitante"}",
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (isLogged) {
                                      userProvider.signOut();
                                    } else {
                                      Navigator.of(context).pushNamed('/login');
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(isLogged ? Icons.logout : Icons.login, size: 20, color: Colors.black),
                                        const SizedBox(width: 8),
                                        Text(
                                          isLogged ? "Sair" : "Login",
                                          style: const TextStyle(color: Colors.black, fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return Column(
                        children: [
                          // Mostrar opção de cadastrar bar apenas se estiver logado
                          if (userProvider.isLoggedIn() && userProvider.userEmail =="kelvindc@hotmail.com")
                            ListTile(
                              leading: const Icon(Icons.add_business),
                              title: const Text("Cadastrar Bar"),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CadastroBar(),
                                  ),
                                );
                              },
                            ),
                          // Mostrar opções de master se for usuário master
                          if (userProvider.isLoggedIn() && userProvider.isMaster)
                            ListTile(
                              leading: const Icon(Icons.admin_panel_settings),
                              title: const Text("Painel Admin"),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                                );
                              },
                            ),
                          // Outras opções do menu
                          ListTile(
                            leading: Icon(Icons.home), // não precisa mais definir cor aqui
                            title: Text("Início"),
                            onTap: () {
                              Navigator.of(context).pushNamed('/');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.search),
                            title: Text(
                              "Buscar Bares",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            onTap: () {
                              // Navigator.of(context).pushNamed('/search');
                            },
                          ),
                          if (userProvider.isLoggedIn())
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text(
                                "Meu Perfil",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              onTap: () {
                                // Navigator.of(context).pushNamed('/profile');
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}