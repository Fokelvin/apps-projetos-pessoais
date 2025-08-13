import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/map_screen.dart';
import '../drawer/drawer.dart';
import '../models/bar_model.dart';
import '../widgets/bar_card.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> bares = [];
  List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _buscarBares();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearPageStorage();
    });
  }

  void _clearPageStorage() {
    try {
      final pageStorage = PageStorage.maybeOf(context);
      if (pageStorage != null) {
        pageStorage.writeState(context, null);
      }
    } catch (e) {
      //print('Erro ao limpar PageStorage: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sports_bar_sharp,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Meu Buteco",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Lista de butecos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child:
                    bares.isEmpty || bares.length != _expanded.length
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                          itemCount: bares.length,
                          itemBuilder: (context, index) {
                            final bar = bares[index];
                            final lat = BarModel.parseCoordinate(
                              bar['lat'],
                              'lat',
                            );
                            final lng = BarModel.parseCoordinate(
                              bar['long'],
                              'long',
                            );

                            return BarCard(
                              bar: bar,
                              lat: lat,
                              lng: lng,
                              expanded: _expanded[index],
                              onExpansionChanged: (expanded) {
                                if (mounted && index < _expanded.length) {
                                  setState(() {
                                    _expanded[index] = expanded;
                                  });
                                }
                              },
                              endereco: BarModel.getEndereco,
                            );
                          },
                        ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[900],
        backgroundColor: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => MapBarScreen()));
          } else {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        ],
      ),
    );
  }

  void _buscarBares() async {
    try {
      final lista = await BarModel.buscarBares();
      if (mounted) {
        _clearPageStorage();

        setState(() {
          bares = lista;
          _expanded = List.generate(lista.length, (_) => false);
        });
      }
    } catch (e) {
      Logger().e('Erro ao buscar bares: $e');
      if (mounted) {
        setState(() {
          bares = [];
          _expanded = [];
        });
      }
    }
  }
}
