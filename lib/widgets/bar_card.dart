import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/bar_screen.dart';
import 'package:meu_buteco/screens/map_scren.dart';
import 'ratings_widget.dart';
import '../screens/rating_screen.dart';
import '../models/rating_model.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class BarCard extends StatefulWidget {
  final Map<String, dynamic> bar;
  final double lat;
  final double lng;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;
  final Future<String> Function(double, double) endereco;

  const BarCard({
    super.key,
    required this.bar,
    required this.lat,
    required this.lng,
    required this.expanded,
    required this.onExpansionChanged,
    required this.endereco,
  });

  @override
  State<BarCard> createState() => _BarCardState();
}

class _BarCardState extends State<BarCard> {
  // Chave para forçar reconstrução do FutureBuilder
  Key _futureBuilderKey = UniqueKey();

  void _atualizarAvaliacoes() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    String? enderecoAtual;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween<double>(begin: 0.0, end: 0.5).animate(animation),
                child: child,
              ),
              child: Icon(
                widget.expanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                key: ValueKey(widget.expanded),
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.expanded ? "ver menos" : "ver mais",
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
        leading: SizedBox(
          width: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                backgroundImage: (widget.bar["linkImagem"] != null && widget.bar["linkImagem"].toString().isNotEmpty)
                    ? NetworkImage(widget.bar["linkImagem"])
                    : const AssetImage('assets/icon/icon.png') as ImageProvider,
                child: (widget.bar["linkImagem"] == null || widget.bar["linkImagem"].toString().isEmpty)
                    ? null
                    : null,
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
        title: Text(widget.bar['nome'] ?? 'Nome não informado'),
        subtitle: FutureBuilder<String>(
          future: widget.endereco(widget.lat, widget.lng),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Buscando endereço...");
            }
            if (snapshot.hasError) {
              return const Text("Erro ao buscar endereço");
            }
            enderecoAtual = snapshot.data;
            return Text(enderecoAtual ?? "Endereço não encontrado");
          },
        ),
        onExpansionChanged: widget.onExpansionChanged,
        children: [
          Container(
            constraints: const BoxConstraints(
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Avaliações",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<Map<String, dynamic>>(
                      key: _futureBuilderKey,
                      future: AvaliacaoModel.calcularMediaAvaliacoes(widget.bar['id'] ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final data = snapshot.data ?? {
                          'success': true,
                          'mediaGeral': 0.0,
                          'medias': {
                            'banheiro': 0.0,
                            'bebidas': 0.0,
                            'comidas': 0.0,
                            'atendimento': 0.0,
                            'precos': 0.0,
                          },
                          'totalAvaliacoes': 0,
                        };

                        final medias = (data['medias'] ?? {
                          'banheiro': 0.0,
                          'bebidas': 0.0,
                          'comidas': 0.0,
                          'atendimento': 0.0,
                          'precos': 0.0,
                        }) as Map<String, dynamic>;
                        final totalAvaliacoes = (data['totalAvaliacoes'] is int) ? data['totalAvaliacoes'] as int : 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (totalAvaliacoes > 0)
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Média Geral: ${data['mediaGeral'].toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Total de avaliações: $totalAvaliacoes',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Center(
                                child: Text(
                                  'Seja o primeiro a avaliar!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.wc, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Expanded(child: Text("Banheiro")),
                                RatingsWidget(rating: medias['banheiro']),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.local_bar, size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                const Expanded(child: Text("Bebidas")),
                                RatingsWidget(rating: medias['bebidas']),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.restaurant, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                const Expanded(child: Text("Comidas")),
                                RatingsWidget(rating: medias['comidas']),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.group, size: 16, color: Colors.purple),
                                const SizedBox(width: 8),
                                const Expanded(child: Text("Atendimento")),
                                RatingsWidget(rating: medias['atendimento']),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.currency_exchange, size: 16, color: Colors.amber),
                                const SizedBox(width: 8),
                                const Expanded(child: Text("Preços")),
                                RatingsWidget(rating: medias['precos']),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BarScreen(
                                  bar: widget.bar,
                                  endereco: enderecoAtual ?? "Endereço não encontrado",
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Ver tudo",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            if(!userProvider.isLoggedIn()){
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Voce precisa estar logado para avaliar')),
                              );
                              Navigator.of(context).pushNamed('/login');
                              return;
                            }
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RatingScreen(
                                  barId: widget.bar['id'] ?? '',
                                ),
                              ),
                            );
                            _atualizarAvaliacoes();
                          },
                          child: const Text(
                            "Avaliar",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MapBarScreen(
                                  lat: widget.lat,
                                  long: widget.lng,
                                  barName: widget.bar['nome'],
                                )
                              )
                            );
                          },
                          child: const Text(
                            "Ver no mapa",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}