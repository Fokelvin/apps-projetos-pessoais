// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:meu_buteco/models/bar_model.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // para usar kIsWeb

class CadastroBar extends StatefulWidget {
  const CadastroBar({super.key});

  @override
  State<CadastroBar> createState() => _CadastroBarState();
}

class _CadastroBarState extends State<CadastroBar> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final linkController = TextEditingController();
  final enderecoController = TextEditingController();

  late final DotEnv env;

  // Controllers para horários
  final segundaSextaController = TextEditingController();
  final sabadoController = TextEditingController();
  final domingoController = TextEditingController();

  // Estados para checkboxes
  bool jukebox = false;
  bool ambiente = false;
  bool aoVivo = false;
  bool semMusica = false;
  bool tv = false;
  bool telao = false;
  bool wifi = false;

  // Variáveis para armazenar as coordenadas
  double? latitude;
  double? longitude;
  final googleApiKey =
      kIsWeb
          ? dotenv.env['GOOGLE_PLACES_API_KEY_WEB']
          : dotenv.env['GOOGLE_PLACES_API_KEY_MOBILE'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar novo Bar"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Informações básicas
                const Text(
                  "Informações Básicas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: "Nome do Bar",
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Informe o nome"
                              : null,
                ),

                const SizedBox(height: 16),

                // Campo de busca de endereço
                GooglePlaceAutoCompleteTextField(
                  textEditingController: enderecoController,
                  googleAPIKey: googleApiKey ?? '',
                  inputDecoration: const InputDecoration(
                    labelText: "Endereço",
                    border: OutlineInputBorder(),
                    hintText: "Digite o endereço do bar",
                  ),
                  debounceTime: 800,
                  countries: ["br"],
                  focusNode: FocusNode(),
                  textInputAction: TextInputAction.done,
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    // Aqui recebemos as coordenadas quando um endereço é selecionado
                    latitude = double.parse(prediction.lat!);
                    longitude = double.parse(prediction.lng!);
                  },
                  itemClick: (Prediction prediction) {
                    enderecoController.text = prediction.description!;
                    enderecoController.selection = TextSelection.fromPosition(
                      TextPosition(offset: prediction.description!.length),
                    );
                  },
                  seperatedBuilder: const Divider(),
                  // Opcional: Estilizar os itens da lista de sugestões
                  itemBuilder: (context, index, Prediction prediction) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 10),
                          Expanded(child: Text(prediction.description!)),
                        ],
                      ),
                    );
                  },
                  validator: (value, context) {
                    if (value == null || value.isEmpty) {
                      return "Informe o endereço";
                    }
                    if (latitude == null || longitude == null) {
                      return "Selecione um endereço válido da lista";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: "Link da Imagem",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      linkController.text =
                          "https://rzhnjeisknsdgaogvxfg.supabase.co/storage/v1/object/public/imagens//logo.jpeg";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Música
                const Text(
                  "Música",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text("Jukebox"),
                        value: jukebox,
                        onChanged: (value) {
                          setState(() {
                            jukebox = value ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text("Ambiente"),
                        value: ambiente,
                        onChanged: (value) {
                          setState(() {
                            ambiente = value ?? false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text("Ao-Vivo"),
                        value: aoVivo,
                        onChanged: (value) {
                          setState(() {
                            aoVivo = value ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text("Sem Música"),
                        value: semMusica,
                        onChanged: (value) {
                          setState(() {
                            semMusica = value ?? false;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Transmissão de jogos
                const Text(
                  "Transmissão de Jogos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text("TV"),
                        value: tv,
                        onChanged:
                            (value) => setState(() => tv = value ?? false),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text("Telão"),
                        value: telao,
                        onChanged:
                            (value) => setState(() => telao = value ?? false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Wi-Fi
                const Text(
                  "Wi-Fi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text("Possui Wi-Fi"),
                  value: wifi,
                  onChanged: (value) => setState(() => wifi = value ?? false),
                ),

                const SizedBox(height: 24),

                // Horário de funcionamento
                const Text(
                  "Horário de Funcionamento",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: segundaSextaController,
                  decoration: const InputDecoration(
                    labelText: "Segunda a Sexta (ex: 10:00 às 24:00)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: sabadoController,
                  decoration: const InputDecoration(
                    labelText: "Sábado (ex: 10:00 às 24:00)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: domingoController,
                  decoration: const InputDecoration(
                    labelText: "Domingo (ex: Fechado)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 32),

                // Botão de salvar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          String enderecoFinal =
                              enderecoController.text.trim().isEmpty
                                  ? "Não informado"
                                  : enderecoController.text.trim();
                          final barModel = BarModel(
                            nome: nomeController.text,
                            latitude:
                                latitude?.toString() ??
                                "0.0", // Convertendo double para string
                            longitude:
                                longitude?.toString() ??
                                "0.0", // Convertendo double para string
                            linkImagem: linkController.text,
                            endereco: enderecoFinal,
                            musica: {
                              'jukebox': jukebox,
                              'ambiente': ambiente,
                              'aoVivo': aoVivo,
                              'semMusica': semMusica,
                            },
                            transmissao: {'tv': tv, 'telao': telao},
                            wifi: wifi,
                            horario: {
                              'segundaSexta': segundaSextaController.text,
                              'sabado': sabadoController.text,
                              'domingo': domingoController.text,
                            },
                          );
                          await barModel.salvarNoFirebase();
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Bar cadastrado com sucesso!"),
                            ),
                          );
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/home', (route) => false);
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Erro ao cadastrar bar: $e"),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Salvar", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    linkController.dispose();
    segundaSextaController.dispose();
    sabadoController.dispose();
    domingoController.dispose();
    super.dispose();
  }
}
