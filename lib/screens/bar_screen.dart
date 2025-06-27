import 'package:flutter/material.dart';
import 'package:meu_buteco/screens/map_scren.dart';
import 'package:meu_buteco/widgets/ratings_widget.dart';

class BarScreen extends StatelessWidget {

  final Map<String, dynamic> bar;
  final String endereco;

  const BarScreen({super.key, required this.bar, required this.endereco});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informações totais", textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(bar["linkImagem"] !=null)
              Image.network(
                bar["linkImagem"],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.red),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 100,
                        ),
                        child: Text(
                          "Endereço:",
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 100,
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MapBarScreen(),
                              ),
                            );
                          },
                          child: Text(
                            endereco,
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.wc, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(child: Text("Banheiro")),
                      RatingsWidget(rating: 4.0),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_bar, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Expanded(child: Text("Bebidas")),
                      RatingsWidget(rating: 3.5),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.restaurant, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(child: Text("Comidas")),
                      RatingsWidget(rating: 4.5),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.group, size: 20, color: Colors.purple),
                      const SizedBox(width: 8),
                      const Expanded(child: Text("Atendimento")),
                      RatingsWidget(rating: 5.0),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.currency_exchange, size: 20, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Expanded(child: Text("Preços")),
                      RatingsWidget(rating: 3.0),
                    ],
                  ),
                  //Musica
                  const SizedBox(height: 8),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_note, size: 20),
                      const Text("Musica",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Jukebox"),
                            Icon(
                              bar['musica']?['jukebox'] == true 
                                ? Icons.check_box 
                                : Icons.check_box_outline_blank, 
                              size: 18
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Ambiente"),
                            Icon(
                              bar['musica']?['ambiente'] == true 
                                ? Icons.check_box 
                                : Icons.check_box_outline_blank, 
                              size: 18
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Ao-Vivo"),
                            Icon(
                              bar['musica']?['aoVivo'] == true 
                                ? Icons.check_box 
                                : Icons.check_box_outline_blank, 
                              size: 18
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Sem Musica"),
                            Icon(
                              bar['musica']?['semMusica'] == true 
                                ? Icons.check_box 
                                : Icons.check_box_outline_blank, 
                              size: 18
                            ),
                          ],
                        ),
                      ],
                    ), 
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 4),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.sports_soccer, size: 20),
                          SizedBox(width: 4),
                          Text("Transmissão de jogos",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("TV"),
                                  Icon(
                                    bar['transmissao']?['tv'] == true 
                                      ? Icons.check_box 
                                      : Icons.check_box_outline_blank, 
                                    size: 20
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 8),
                                  const Text("Telao"),
                                  Icon(
                                    bar['transmissao']?['telao'] == true 
                                      ? Icons.check_box 
                                      : Icons.check_box_outline_blank, 
                                    size: 20
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 4),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.signal_wifi_statusbar_4_bar_rounded, size: 20),
                          const SizedBox(width: 4),
                          const Text("WI-Fi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            bar['wifi'] == true 
                              ? Icons.check_box 
                              : Icons.check_box_outline_blank, 
                            size: 20
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.access_time, size: 20),
                          SizedBox(width: 4),
                          Text("Horario de funcioamento",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(width: 4),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 20),
                              Text("Segunda a sexta: ${bar['horario']?['segundaSexta'] ?? 'Não informado'}"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 20),
                              Text("Sábado: ${bar['horario']?['sabado'] ?? 'Não informado'}"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 20),
                              Text("Domingo: ${bar['horario']?['domingo'] ?? 'Não informado'}"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 4),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}