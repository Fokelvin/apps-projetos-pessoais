import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meu_buteco/widgets/bar_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _busca = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buscar buteco")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Digite o nome",
                border: OutlineInputBorder(),
                prefix: Icon(Icons.search),
              ),
              onChanged: (valor) {
                setState(() {
                  _busca = valor.trim();
                });
              },
            ),
          ),
          Expanded(
            child:
                _busca.isEmpty
                    ? Center(child: Text("Digite para buscar..."))
                    : StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection("bares")
                              .where('nome', isGreaterThanOrEqualTo: _busca)
                              .where(
                                'nome',
                                isLessThanOrEqualTo: '$_busca\uf8ff',
                              )
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text("Nenhum bar encontrado"));
                        }
                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final bar =
                                docs[index].data() as Map<String, dynamic>;
                            bar['id'] = docs[index].id;
                            return ListTile(
                              title: Text(bar['nome'] ?? 'Sem nome'),
                              subtitle: Text(bar['endereco'] ?? ''),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => Scaffold(
                                          appBar: AppBar(
                                            title: Text(bar["nome"] ?? 'Bar'),
                                          ),
                                          body: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: BarCard(
                                              bar: bar,
                                              lat: bar['lat'],
                                              lng: bar['long'],
                                              expanded: true,
                                              onExpansionChanged: (_) {},
                                              endereco:
                                                  (lat, lng) async =>
                                                      bar['endereco'] ?? '',
                                            ),
                                          ),
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
