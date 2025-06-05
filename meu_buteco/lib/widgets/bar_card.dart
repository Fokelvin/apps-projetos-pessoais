import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/bar_screen.dart';
import 'avaliacoes_widget.dart';

class BarCard extends StatelessWidget {
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
  Widget build(BuildContext context) {

    String? enderecoAtual;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.expand_more),
            const SizedBox(height: 2),
            Text(
              expanded ? "ver menos" : "ver mais",
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
                backgroundImage: bar["linkImagem"] != null
                    ? NetworkImage(bar["linkImagem"])
                    : null,
                child: bar["linkImagem"] == null
                    ? const Icon(Icons.sports_bar)
                    : null,
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
        title: Text(bar['nome'] ?? 'Nome não informado'),
        subtitle: FutureBuilder<String>(
          future: endereco(lat, lng),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Buscando endereço...");
            }
            if (snapshot.hasError) {
              return const Text("Erro ao buscar endereço");
            }
            final enderecoAtual = snapshot.data ?? "Endereço não encontrado";
            return Text(enderecoAtual);
          },
        ),
        onExpansionChanged: onExpansionChanged,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxHeight: 250,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wc, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Expanded(child: Text("Banheiro")),
                            AvaliacoesWidget(rating: 4.0),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.local_bar, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Expanded(child: Text("Bebidas")),
                            AvaliacoesWidget(rating: 3.5),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.music_note, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            const Expanded(child: Text("Comidas")),
                            AvaliacoesWidget(rating: 4.5),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.group, size: 16, color: Colors.purple),
                            const SizedBox(width: 8),
                            const Expanded(child: Text("Atendimento")),
                            AvaliacoesWidget(rating: 5.0),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 8),
                            const Expanded(child: Text("Preços")),
                            AvaliacoesWidget(rating: 3.0),
                          ],
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
                                     bar: bar,
                                     endereco: enderecoAtual ?? "Endereco nao encontrado",
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
                              onPressed: () {
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
                                // TODO: Implementar ver no mapa
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