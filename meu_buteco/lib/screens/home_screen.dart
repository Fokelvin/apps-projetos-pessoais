import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/cadastro_bar_screen.dart';
import 'package:meu_buteco/screens/mapa_scren.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

    final List<Map<String, String>> bares = [
      {'nome': 'Bar do Zé', 'endereco': 'Rua 1, 123'},
      {'nome': 'Buteco da Ana', 'endereco': 'Av. Central, 456'},
      {'nome': 'Bar do João', 'endereco': 'Praça 7, 789'},
    ];
  @override
  Widget build(BuildContext context) {

    //Scafold
    return Scaffold(
      //Drawer
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                "Opções",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_business),
              title: Text("Cadastrar Bar"),
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CadastroBar()),
                );
              },
            )
          ],
        ),
      ),
      
      //AppBar
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_bar,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                SizedBox(width: 8),
                Text(
                  "Meu Buteco",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              ],
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      //PageView
      body: PageView(
        children: [
          // Página de lista de bares com título "Destaques"
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Destaques',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: bares.length,
                  itemBuilder: (context, index) {
                    final bar = bares[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/48',
                          ),
                        ),
                        title: Text(bar['nome']!),
                        subtitle: Text(bar['endereco']!),
                        onTap: () {
                          // ação ao tocar no card
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Página do mapa
          MapaScreen(),
        ],
      ),
      
      //Navigation icons
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Página inicial selecionada
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MapaScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }
}