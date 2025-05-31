import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/cadastro_bar_screen.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    Widget buildDrawerBack() => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 203, 236, 241),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        )
      ),
    );

    return Drawer(
      child: Stack(
        children: <Widget>[
          buildDrawerBack(),
          ListView(
            padding: EdgeInsets.only(left: 32.0, top: 16.0),
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 16.0),
                padding: EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 8.0),
                height: 170.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Opções",
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, child){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Olá, ${userProvider.isLoggedIn() ? userProvider.userName : "Visitante"}",
                                style: TextStyle(
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
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.login, size: 20),
                                      SizedBox(width: 8),
                                      Text("Login"),
                                    ],
                                  ),
                                ),
                              ),
                              if (userProvider.isLoggedIn())
                                ListTile(
                                  leading: Icon(Icons.add_business),
                                  title: Text("Cadastrar Bar"),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => CadastroBar()),
                                    );
                                  },
                                ),
                            ]
                          );  
                        }
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Column(
                    children: [
                      // Mostrar opção de cadastrar bar apenas se estiver logado
                      if (userProvider.isLoggedIn())
                        ListTile(
                          leading: Icon(Icons.add_business),
                          title: Text("Cadastrar Bar"),
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
                          leading: Icon(Icons.admin_panel_settings),
                          title: Text("Painel Admin"),
                          onTap: () {
                            // Navegar para tela de admin
                            // Navigator.of(context).pushNamed('/admin');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                            );
                          },
                        ),
                      
                      // Outras opções do menu
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text("Início"),
                        onTap: () {
                          Navigator.of(context).pushNamed('/');
                        },
                      ),
                      
                      ListTile(
                        leading: Icon(Icons.search),
                        title: Text("Buscar Bares"),
                        onTap: () {
                          // Navigator.of(context).pushNamed('/search');
                        },
                      ),
                      
                      if (userProvider.isLoggedIn())
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text("Meu Perfil"),
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
    );
  }
}