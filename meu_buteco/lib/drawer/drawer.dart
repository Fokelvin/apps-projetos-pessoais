import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/cadastro_bar_screen.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildDrawerBack() => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    return Drawer(
      child: IconTheme(
        data: const IconThemeData(
          color: Colors.white, // todos os ícones filhos serão brancos
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            listTileTheme: const ListTileThemeData(
              selectedColor: Colors.white, // cor do texto/ícone selecionado
              iconColor: Colors.white,     // cor dos ícones
              textColor: Colors.white,     // cor do texto
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
                    height: 170.0,
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
                                    Navigator.of(context).pushNamed('/login');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.login, size: 20),
                                        const SizedBox(width: 8),
                                        const Text("Login"),
                                      ],
                                    ),
                                  ),
                                ),
                                if (userProvider.isLoggedIn())
                                  ListTile(
                                    leading: Icon(Icons.add_business),
                                    title: Text(
                                      "Início",
                                      style: const TextStyle(color: Colors.white), // força branco
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => CadastroBar()),
                                      );
                                    },
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
                          if (userProvider.isLoggedIn())
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