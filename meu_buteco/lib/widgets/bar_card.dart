import 'package:flutter/material.dart';

class BarCard extends StatelessWidget {
  final Map<String, dynamic> bar;
  final double lat;
  final double lng;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;
  final Future<String> Function(double, double) getEndereco;

  const BarCard({
    super.key,
    required this.bar,
    required this.lat,
    required this.lng,
    required this.expanded,
    required this.onExpansionChanged,
    required this.getEndereco,
  });

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
          future: getEndereco(lat, lng),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Buscando endereço...");
            }
            if (snapshot.hasError) {
              return const Text("Erro ao buscar endereço");
            }
            return Text(snapshot.data ?? "Endereço não encontrado");
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
                    if (bar["linkImagem"] != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              bar["linkImagem"],
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wc, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(child: Text("Banheiro limpo e bem cuidado")),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.local_bar, size: 16, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(child: Text("Ótima variedade de bebidas")),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.music_note, size: 16, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(child: Text("Ambiente com boa música")),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.group, size: 16, color: Colors.purple),
                            SizedBox(width: 8),
                            Expanded(child: Text("Atendimento cordial")),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 8),
                            Expanded(child: Text("Preços justos")),
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