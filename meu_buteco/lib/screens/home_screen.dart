import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/mapa_scren.dart';
import '../drawer/drawer.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  PageController _pageController = PageController();

  final List<Map<String, String>> bares = [
    {'nome': 'Bar do Zé', 'endereco': 'Rua 1, 123'},
    {'nome': 'Buteco da Ana', 'endereco': 'Av. Central, 456'},
    {'nome': 'Bar do João', 'endereco': 'Praça 7, 789'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer
      drawer: const AppDrawer(),
      // AppBar
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sports_bar_sharp,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),                
                Icon(Icons.favorite,
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

      // PageView
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
                            'https://placehold.co/600x400.png',
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
      
      // Navigation icons
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,      // Ícone/texto selecionado branco
        unselectedItemColor: Colors.grey[900],  // Ícone/texto não selecionado levemente acinzentado
        backgroundColor: Theme.of(context).colorScheme.primary, // Fundo igual ao AppBar
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
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